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
      if @config[:api_from]
        @api_from = @config[:api_from]
      else
        @api_from = ""
      end
      if Settings.activate_microinsurance
        particular = "TO RECORD DEPOSIT COLLECTION OF #{@branch.name.upcase}"
      else
        particular = "TO RECORD INSURANCE FUND TRANSFER OF #{@branch.name.upcase}"
      end

      @members  = []

      @data = {
        or_number: "",
        ar_number: "",
        finalize: false,
        records: [],
        headers: [],
        totals: [],
        total_collected: 0.00,
        particular: particular,
        is_remote_deposit: User::REMOTE_ROLES.include?(@user.roles.last),
        reference_number: "",
        api_from: @api_from,
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
