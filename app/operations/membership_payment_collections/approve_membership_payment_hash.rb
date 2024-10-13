module MembershipPaymentCollections
  class ApproveMembershipPaymentHash
    def initialize(config:)
      @config             = config
      @date_paid          = @config[:date_paid]
      @membership_payment = @config[:membership_payment]
      @user               = @config[:user]
      @particular         = @config[:particular]
      @member             = @config[:member]
      @amount             = @membership_payment[:amount].try(:to_f).round(2)

      @membership_settings  = nil

      Settings.memberships.each do |s|
        if s.name == @membership_payment[:account_subtype]
          @membership_settings = s
        end
      end

      # Trap if no settings found
      if @membership_settings.blank?
        raise "No settings found for membership_payment #{@membership_payment}"
      end

      @membership_payment_record  = MembershipPaymentRecord.new(
                                      membership_name: @membership_settings.name,
                                      membership_type: @membership_settings.type,
                                      member: @member,
                                      amount: @amount,
                                      status: "paid",
                                      date_paid: @date_paid
                                    )
    end

    def execute!
      @membership_payment_record.save!

      if @membership_settings.type == "Cooperative" and @membership_settings.is_main == true
        identification_number = @member.identification_number

        if identification_number.blank?
          identification_number = ::Members::GenerateMemberIdentificationNumber.new(
                                    member: @member
                                  ).execute!

          while Member.where("upper(identification_number) = ?", identification_number.upcase).count > 0 do
            # Update branch counter
            old_counter = @member.branch.member_counter || 0
            new_counter = old_counter + 1
            @member.branch.update!(member_counter: new_counter)

            identification_number = ::Members::GenerateMemberIdentificationNumber.new(
                                      member: @member
                                    ).execute!
          end
        end
        member_data = @member.data.with_indifferent_access
        member_data[:hide_status] = "active"
        @member.update!(
          status: "active",
          identification_number: identification_number,
          data: member_data
        )

        # Update branch counter
        old_counter = @member.branch.member_counter || 1
        new_counter = old_counter + 1

        @member.branch.update!(member_counter: new_counter)
      end

      if @membership_settings.type == "Insurance" and @membership_settings.is_main == true
        @member.update!(
          insurance_status: "inforce"
        )
      end

      @membership_payment_record
    end
  end
end
