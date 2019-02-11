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

      # Progress
      @total_accounts = @member_accounts.size
      @counter        = 0
      @progress       = 0.00
    end

    def execute!
      # Build data
      @interest_member_accounts.each do |s|
        total = {
          account_type: s.account_type,
          account_subtype: s.account_subtype,
          interest: 0.00
        }

        accounts  = @member_accounts.where(
                      account_type: s.account_type, 
                      account_subtype: s.account_subtype
                    )

        accounts.each do |a|
          result  = ::MemberAccounts::ComputeInterest.new(
                      config: {
                        member_account: a,
                        closing_date: @closing_date,
                        account_type: s.account_type,
                        account_subtype: s.account_subtype,
                        account_settings: s
                      }
                    ).execute!

          if result[:interest] > 0
            total[:interest] += result[:interest].to_f.round(2)
            @data[:total_interest] += result[:interest].to_f.round(2)
            @data[:records] << result
          end

          @counter += 1

          @progress = (@counter.to_f / @total_accounts.to_f) * 100

          # Broadcast progress
          #ActionCable.server.broadcast 'monthly_closing_collections_channel', { id: @monthly_closing_collection.id, progress: @progress }
        end
      end

      # Build accounting entry
#      @data[:accounting_entry]  = ::MonthlyClosingCollections::BuildAccountingEntry.new(
#                                    config: {
#                                      data: @data,
#                                      branch: @branch,
#                                      interest_member_accounts: @interest_member_accounts,
#                                      user: @user,
#                                      collection_date: @collection_date,
#                                      closing_date: @closing_date
#                                    }
#                                  ).execute!

      # Attach meta
      @monthly_closing_collection.meta  = @meta

      # Attach data
      @monthly_closing_collection.data  = @data


      @monthly_closing_collection.status  = "pending"
      @monthly_closing_collection.save!

      @progress = 100

      #ActionCable.server.broadcast 'monthly_closing_collections_channel', { id: @monthly_closing_collection.id, progress: @progress }

      @monthly_closing_collection
    end
  end
end
