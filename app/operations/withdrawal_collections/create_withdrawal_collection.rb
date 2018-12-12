module WithdrawalCollections
  class CreateWithdrawalCollection
    def initialize(config:)
      @config           = config
      @collection_date  = @config[:collection_date].try(:to_date) || Date.today
      @user             = @config[:user]
      @branch           = Branch.where(id: @config[:branch_id]).first

      @default_withdrawal_accounts  = Settings.default_withdrawal_accounts
      @withdrawal_collection        = WithdrawalCollection.new(
                                        collection_date: @collection_date,
                                        branch: @branch
                                      )

      @members  = []

      @data = {
        or_number: "",
        ar_number: "",
        records: [],
        headers: [],
        totals: [],
        total_collected: 0.00
      }
    end

    def execute!
      load_headers_and_totals!

      # Load accounting entry
      @data[:accounting_entry]  = ::WithdrawalCollections::BuildAccountingEntry.new(
                                    config: {
                                      branch: @branch,
                                      data: @data,
                                      user: @user
                                    }
                                  ).execute!

      @withdrawal_collection.data = @data
      @withdrawal_collection.save!

      @withdrawal_collection
    end

    private

    def load_headers_and_totals!
      # DEPOSITS: default_withdrawal_accounts
      @default_withdrawal_accounts.each do |c|
        @data[:headers] << c.account_subtype

        @data[:totals] << {
          record_type: c.account_type,
          key: c.account_subtype,
          amount: 0.00
        }
      end
    end
  end
end
