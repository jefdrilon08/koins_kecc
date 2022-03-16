module InsuranceMonthlyClosingCollections
  class Save
    def initialize(config:)
      @config = config

      @closing_date = @config[:closing_date]
      @user         = @config[:user]
      @branch       = @config[:branch]
      
      @insurance_monthly_closing_collection = @config[:insurance_monthly_closing_collection]
      @account_subtype                      = @insurance_monthly_closing_collection.account_subtype

      @meta = {
        prepared_by: {
          id: @user.id,
          first_name: @user.first_name,
          last_name: @user.last_name,
          full_name: @user.full_name
        },
        branch: {
          id: @branch.id,
          name: @branch.name
        }
      }

      @data = {
        total_interest: 0.00,
        totals: [],
        records: []
      }

      @insurance_interest_member_accounts = Settings.insurance_interest_member_accounts

      if @insurance_interest_member_accounts.blank?
        raise "Config not found: insurance_interest_member_accounts"
      end

      @account_settings = nil

      @insurance_interest_member_accounts.each do |s|
        if s.account_subtype == @account_subtype
          @account_settings = s
        end
      end

      if @account_settings.blank?
        raise "account_settings not found"
      end

      validated_members_ids = MemberAccountValidationRecord.where("data->>'is_void' = ?", "false").pluck(:member_id)

      @member_accounts  = MemberAccount.joins(:member).where(
                            "members.branch_id = ? AND members.insurance_status IN (?) AND account_subtype = ? AND members.id NOT IN (?)",
                            @branch.id,
                            ["inforce", "lapsed"],
                            @account_settings.account_subtype,
                            validated_members_ids
                          )

      if @insurance_monthly_closing_collection.blank?
        @insurance_monthly_closing_collection = InsuranceMonthlyClosingCollection.new
      end

      # Progress
      @total_accounts = @member_accounts.size
      @counter        = 0
      @progress       = 0.00
    end

    def execute!
      # Build data
      accounts  = @member_accounts.where(
                    account_type: @account_settings.account_type, 
                  )

      accounts.each do |a|
        result  = ::MemberAccounts::ComputeInsuranceInterest.new(
                    member_account: a,
                    closing_date: @closing_date,
                    account_settings: @account_settings
                  ).execute!

        if result[:interest] > 0
          @data[:records] << result
          @data[:total_interest] += result[:interest].to_f.round(2)
        end
      end

      if Settings.activate_microinsurance
        # Build accounting entry
        default_branch_id = Settings.try(:defaults).try(:default_branch).try(:id)
        @default_branch = Branch.find(default_branch_id)

        @data[:accounting_entry]  = ::InsuranceMonthlyClosingCollections::BuildAccountingEntry.new(
                                      config: {
                                        data: @data,
                                        branch: @branch,
                                        default_branch: @default_branch,
                                        settings: @account_settings,
                                        user: @user,
                                        collection_date: @closing_date,
                                        closing_date: @closing_date
                                      }
                                    ).execute!
      end

      # Attach meta
      @insurance_monthly_closing_collection.meta  = @meta

      # Attach data
      @insurance_monthly_closing_collection.data  = @data


      @insurance_monthly_closing_collection.status  = "pending"
      @insurance_monthly_closing_collection.save!

      @progress = 100

      #ActionCable.server.broadcast 'monthly_closing_collections_channel', { id: @monthly_closing_collection.id, progress: @progress }

      @insurance_monthly_closing_collection
    end
  end
end
