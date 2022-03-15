module CommissionCollections
  class AddTransactionFee
    def initialize(config:)
      @config = config

      @transaction_fee       = @config[:transaction_fee]
      @commission_collection = @config[:commission_collection]
      @start_date            = @commission_collection.start_date
      @end_date              = @commission_collection.end_date
      @category              = @commission_collection.category
      @date_prepared         = @commission_collection.date_prepared
      @book                  = @commission_collection.data.with_indifferent_access[:accounting_entry][:book]
      @user                  = @config[:user]
      @data                  = @commission_collection.data.with_indifferent_access

      @default_branch_id     = Settings.try(:defaults).try(:default_branch).try(:id)
      @default_branch        = Branch.find(@default_branch_id)
    end

    def execute!
      @data[:transaction_fee]  = @transaction_fee

      config  = {
        commission_collection: @commission_collection,
        user: @user,
        start_date: @start_date,
        end_date: @end_date,
        category: @category,
        default_branch: @default_branch,
        book: @book,
        data: @data
      }

      @data[:accounting_entry]  = ::CommissionCollections::BuildAccountingEntry.new(
                                    config: config
                                  ).execute!

      @commission_collection.update!(data: @data)
    
      @commission_collection
    end
  end
end
