module InsuranceFundTransferCollections
  class CreateInsuranceFundTransferCollection
    def initialize(config:)
      @config                               = config
      @collection_date                      = @config[:collection_date].try(:to_date) || Date.today
      @user                                 = @config[:user]
      @branch                               = Branch.where(id: @config[:branch_id]).first

      @default_fund_transfer_accounts       = Settings.default_deposit_accounts
      @insurance_fund_transfer_collection   = InsuranceFundTransferCollection.new(
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
        total_collected: 0.00,
        particular: "TO RECORD INSURANCE FUND TRANSFER OF #{@branch.name}"
      }
    end

    def execute!
      load_headers_and_totals!

      @insurance_fund_transfer_collection.data = @data
      @insurance_fund_transfer_collection.save!

      @insurance_fund_transfer_collection
    end

    private

    def load_headers_and_totals!
      # DEPOSITS: default_fund_transfer_accounts
      @default_fund_transfer_accounts.each do |c|
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
