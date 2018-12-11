module Members
  class Save
    def initialize(config:)
      super()

      @config       = config
      @member_data  = @config[:member_data]
      @user         = @config[:user]

      @branch = Branch.find(@member_data[:branch_id])
      @center = Center.find(@member_data[:center_id])

      @member = Member.new

      if @member_data[:id].present?
        @member = Member.find(@member_data[:id])
      end
    end

    def execute!
      @member.first_name      = @member_data[:first_name]
      @member.middle_name     = @member_data[:middle_name]
      @member.last_name       = @member_data[:last_name]
      @member.gender          = @member_data[:gender]
      @member.date_of_birth   = @member_data[:date_of_birth]
      @member.civil_status    = @member_data[:civil_status]
      @member.home_number     = @member_data[:home_number]
      @member.mobile_number   = @member_data[:mobile_number]
      @member.place_of_birth  = @member_data[:place_of_birth]
      @member.member_type     = @member_data[:member_type]
      @member.religion        = @member_data[:religion]
      @member.data            = @member_data[:data]

      # Legal Dependents
      ld_remaining_uuids = []
      ld_current_uuids   = @member.legal_dependents.pluck(:id)

      if @member_data[:legal_dependents].size > 0
        @member_data[:legal_dependents].each do |o|
          # Update if any
          if o[:id].present?
            @member.legal_dependents.each_with_index do |ld, i|
              if ld.id == o[:id]
                @member.legal_dependents[i].first_name    = o[:first_name]
                @member.legal_dependents[i].middle_name   = o[:middle_name]
                @member.legal_dependents[i].last_name     = o[:last_name]
                @member.legal_dependents[i].date_of_birth = o[:date_of_birth]
                @member.legal_dependents[i].relationship  = o[:relationship]
                @member.legal_dependents[i].data          = o[:data]

                ld_remaining_uuids << o[:id]
              end
            end
          else
            ld  = LegalDependent.new(
                      first_name: o[:first_name],
                      middle_name: o[:middle_name],
                      last_name: o[:last_name],
                      date_of_birth: o[:date_of_birth],
                      relationship: o[:relationship],
                      data: o[:data]
                    )

            @member.legal_dependents << ld

            ld_remaining_uuids << @member.legal_dependents.last.id
          end
        end
      end

      # Beneficiaries
      b_remaining_uuids = []
      b_current_uuids   = @member.beneficiaries.pluck(:id)

      if @member_data[:beneficiaries].size > 0
        @member_data[:beneficiaries].each do |o|
          # Update if any
          if o[:id].present?
            @member.beneficiaries.each_with_index do |ld, i|
              if ld.id == o[:id]
                @member.beneficiaries[i].first_name     = o[:first_name]
                @member.beneficiaries[i].middle_name    = o[:middle_name]
                @member.beneficiaries[i].last_name      = o[:last_name]
                @member.beneficiaries[i].date_of_birth  = o[:date_of_birth]
                @member.beneficiaries[i].relationship   = o[:relationship]
                @member.beneficiaries[i].is_primary     = o[:is_primary]

                b_remaining_uuids << o[:id]
              end
            end
          else
            @member.beneficiaries <<  Beneficiary.new(
                                        first_name: o[:first_name],
                                        middle_name: o[:middle_name],
                                        last_name: o[:last_name],
                                        date_of_birth: o[:date_of_birth],
                                        relationship: o[:relationship],
                                        is_primary: o[:is_primary]
                                      )
          end
        end
      end

      ld_to_remove_ids  = @member.legal_dependents.where.not(id: ld_remaining_uuids).pluck(:id)
      b_to_remove_ids   = @member.beneficiaries.where.not(id: b_remaining_uuids).pluck(:id)

      #raise ld_to_remove_ids.inspect

      @member.branch      = @branch
      @member.center      = @center
      @member.modifiable  = nil

      @member.save!
      @member = Member.find(@member.id)

      missing_accounts  = ::Members::FetchMissingAccounts.new(
                            config: {
                              member: @member
                            }
                          ).execute!

      if missing_accounts.size > 0
        ::Members::GenerateMissingAccounts.new(
          config: { member: @member }
        ).execute!
      end

      # Remove has many
      LegalDependent.where(member_id: @member.id, id: ld_to_remove_ids).delete_all
      Beneficiary.where(member_id: @member.id, id: b_to_remove_ids).delete_all

      @member
    end
  end
end
