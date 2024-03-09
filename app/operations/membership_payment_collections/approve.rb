module MembershipPaymentCollections
  class Approve
    def initialize(config:)
      @config   = config
      @membership_payment_collection  = @config[:membership_payment_collection]

      @branch   = @membership_payment_collection.branch
      @user     = @config[:user]

      @data = @membership_payment_collection.try(:data).try(:with_indifferent_access)

      @data_id_payments         = @membership_payment_collection.id_payments
      @data_membership_payments = @membership_payment_collection.membership_payments
      @data_equities            = @membership_payment_collection.equities
      @data_insurance           = @membership_payment_collection.insurance
      @data_savings             = @membership_payment_collection.savings
      @data_accounting_entry    = @membership_payment_collection.accounting_entry

      @date_approved  = ::Utils::GetCurrentDate.new(
                          config: {
                            branch: @branch
                          }
                        ).execute!
        @member = Member.new
    end

    def execute!

      post_accounting_entry!

      process_id_payments!
      process_membership_payments!
      process_equities!
      process_insurance!
      process_savings!


      #class sms
      process_sms_blast!


      @data[:approved_by] = @user.full_name

      # Update accounting entry with reference number
      @data[:accounting_entry][:id]               = @accounting_entry.id
      @data[:accounting_entry][:reference_number] = @accounting_entry.reference_number
      @data[:accounting_entry][:status]           = @accounting_entry.status
      @data[:accounting_entry][:approved_by]      = @accounting_entry.approved_by

      @membership_payment_collection.update!(
        status: "approved",
        date_approved: @date_approved,
        data: @data
      )

      @membership_payment_collection
    end

    private

    # Nothing to do here
    def process_id_payments!
      @data_id_payments.each do |o|
        config  = {
          id_payment: o,
          date_paid: @date_approved,
          user: @user,
          particular: @data_accounting_entry[:particular]
        }
      end
    end

    def process_membership_payments!
      @data_membership_payments.each do |o|
        config  = {
          date_paid: @date_approved,
          membership_payment: o,
          member: Member.find(o[:member_id]),
          user: @user,
          particular: @data_accounting_entry[:particular]
        }

        ::MembershipPaymentCollections::ApproveMembershipPaymentHash.new(
          config: config
        ).execute!
      end
    end

    def process_equities!
      @data_equities.each do |o|
        config  = {
          date_paid: @date_approved,
          equity_payment: o,
          user: @user,
          particular: @data_accounting_entry[:particular]
        }

        ::MembershipPaymentCollections::ApproveEquityPaymentHash.new(
          config: config
        ).execute!
      end
    end

    def process_insurance!
      @data_insurance.each do |o|
        config  = {
          date_paid: @date_approved,
          insurance_payment: o,
          user: @user,
          particular: @data_accounting_entry[:particular]
        }

        ::MembershipPaymentCollections::ApproveInsurancePaymentHash.new(
          config: config
        ).execute!
      end
    end

    def process_savings!
      @data_savings.each do |o|
        config  = {
          date_paid: @date_approved,
          savings_payment: o,
          user: @user,
          particular: @data_accounting_entry[:particular]
        }

        ::MembershipPaymentCollections::ApproveSavingsPaymentHash.new(
          config: config
        ).execute!
      end
    end

    def post_accounting_entry!
      # Create new accounting entry
      config  = {
        accounting_entry_data: @data_accounting_entry.with_indifferent_access,
        user: @user
      }

      accounting_entry  = ::Accounting::AccountingEntries::Save.new(
                            config: config
                          ).execute!

      # Post to books
      config  = {
        accounting_entry: accounting_entry,
        user: @user
      }

      @accounting_entry = ::Accounting::AccountingEntries::Approve.new(
                            config: config
                          ).execute!

      @accounting_entry
    end
#sms
    def process_sms_blast!
      @data[:records].each do |rec|
        member = Member.find(rec[:member]["id"])

        if member.mobile_number.present?
          member_data = member.data.with_indifferent_access

          otp = generate_otp

          member_data["sms_code"] = otp.to_s

          member.update(data:member_data)

          # Generate OTP

          config = {
            mobile_number: member.mobile_number,
            content: "PAGBATI SA BAGONG KASAPI \nHI! #{member.first_name} Ikaw ay ganap ng miyembro ng K-COOP simula ngayong #{Date.today} \nI-download ang MY K-COINS sa GooglePlay: \nUsername: #{member.identification_number} \nPassword: password \nOTP: #{otp}" 
            #content: "Your OTP for MyK-Coins: #{otp} \nUsername: #{member.identification_number} \nPassword: password"
          }

          # ::SmsBlast::Send.new(config: config).execute!
          puts config.inspect
        end
      end
    end


    def generate_otp
      rand(100_000..999_999)
    end



  end
end
