module DepositCollections
  class CreateDepositCollection
    def initialize(config:)
      @config           = config
      @collection_date  = @config[:collection_date].try(:to_date) || Date.today
      @user             = @config[:user]
      @branch           = Branch.where(id: @config[:branch_id]).first
      @center           = Center.where(id: @config[:center_id]).first

      @default_deposit_accounts = Settings.default_deposit_accounts

      @deposit_collection  = DepositCollection.new(
                                          collection_date: @collection_date,
                                          branch: @branch,
                                          center: @center
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
      @data[:accounting_entry]  = ::DepositCollections::BuildAccountingEntry.new(
                                    config: {
                                      branch: @branch,
                                      data: @data,
                                      user: @user
                                    }
                                  ).execute!

      @deposit_collection.data = @data
      @deposit_collection.save!

      @deposit_collection
    end

    private

    def load_headers_and_totals!
      # DEPOSITS: default_deposit_accounts
      @default_deposit_accounts.each do |c|
        @data[:headers] << c.account_subtype

        @data[:totals] << {
          record_type: "SAVINGS",
          key: c.account_subtype,
          amount: 0.00
        }
      end
    end
  end
end
