module MonthlyClosingCollections
  class Save
    def initialize(config:)
      @config = config

      @closing_date = @config[:closing_date]
      @user         = @config[:user]
      @branch       = @config[:branch]
      
      @monthly_closing_collection = @config[:monthly_closing_collection]
      @account_subtype            = @monthly_closing_collection.account_subtype

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

      @account_settings = nil

      @interest_member_accounts.each do |s|
        if s.account_subtype == @account_subtype
          @account_settings = s
        end
      end

      if @account_settings.blank?
        raise "account_settings not found"
      end

      @member_accounts  = MemberAccount.joins(:member).where(
                            "members.branch_id = ? AND members.status = ? AND account_subtype = ?",
                            @branch.id,
                            "active",
                            @account_settings.account_subtype
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
      accounts  = @member_accounts.where(
                    account_type: @account_settings.account_type, 
                  )

      accounts.each do |a|
#        result  = ::MemberAccounts::ComputeInterest.new(
#                    config: {
#                      member_account: a,
#                      closing_date: @closing_date,
#                      account_type: @account_settings.account_type,
#                      account_subtype: @account_settings.account_subtype,
#                      account_settings: @account_settings
#                    }
#                  ).execute!

        result  = ::Turkey::ComputeInterest.new(
                    member_account: a,
                    closing_date: @closing_date,
                    account_settings: @account_settings
                  ).execute!

        if result[:interest] > 0
          @data[:records] << result
          @data[:total_interest] += result[:interest].to_f.round(2)
        end
      end

      # Build accounting entry
      @data[:accounting_entry]  = ::MonthlyClosingCollections::BuildAccountingEntry.new(
                                    config: {
                                      data: @data,
                                      branch: @branch,
                                      settings: @account_settings,
                                      user: @user,
                                      collection_date: @closing_date,
                                      closing_date: @closing_date
                                    }
                                  ).execute!

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
