module MonthlyClosingCollections
  class Save
    def initialize(config:)
      @config = config

      @closing_date = @config[:closing_date]
      @user         = @config[:user]
      @branch       = @config[:branch]
      
      @monthly_closing_collection = @config[:monthly_closing_collection]

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
        total_tax: 0.00,
        totals: [],
        records: []
      }

      @interest_member_accounts = Settings.interest_member_accounts

      if @interest_member_accounts.blank?
        raise "Config not found: interest_member_accounts"
      end

      account_types     = []
      account_subtypes  = []

      @interest_member_accounts.each do |o|
        account_types << o.account_type
        account_subtypes << o.account_subtype
      end

      account_types     = account_types.uniq
      account_subtypes  = account_subtypes.uniq

      @member_accounts  = MemberAccount.joins(:member).where(
                            "members.branch_id = ? AND members.status = ? AND account_type IN (?) AND account_subtype IN (?)",
                            @branch.id,
                            "active",
                            account_types,
                            account_subtypes
                          )

      if @monthly_closing_collection.blank?
        @monthly_closing_collection = MonthlyClosingCollection.new
      end
    end

    def execute!
      # Build data
      @member_accounts.each do |o|
        result  = ::MemberAccounts::ComputeInterestAndTax.new(
                    config: {
                      member_account: o,
                      closing_date: @closing_date
                    }
                  ).execute!

        if result[:records].size > 0
          @data[:records] << result
        end
      end

      # Attach meta
      @monthly_closing_collection.meta  = @meta

      # Attach data
      @monthly_closing_collection.data  = @data

      @monthly_closing_collection.status  = "pending"
      @monthly_closing_collection.save!

      @monthly_closing_collection
    end
  end
end
