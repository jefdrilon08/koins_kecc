module Exports
  class SaveAccountTransactionsCsv
    attr_accessor :start_date, :end_date, :file_repository, :csv_object, :account_transactions

    def initialize(start_date:, end_date:)
      @start_date = start_date.try(:to_date) 
      @end_date   = end_date.try(:to_date)

      if @start_date.blank? or @end_date.blank?
        raise "Invalid parameters"
      end

      @member_accounts      = MemberAccount.insurance
      @account_transactions = AccountTransaction.where(
                                "Date(account_transactions.updated_at) >= ? AND Date(account_transactions.updated_at) <= ? AND subsidiary_id IN (?)", 
                                @start_date, 
                                @end_date, 
                                @member_accounts.pluck(:id)
                              )
    end

    def execute!
      cmd = Exports::GenerateAccountTransactionsCsv.new(
              account_transactions: @account_transactions
            )

      @csv_object = cmd.execute!

      @file_repository  = FileRepository.new(
                            file_type: "INSURANCE_ACCOUNT_TRANSACTIONS"
                          )

      @file_repository.file.attach(
        io: StringIO.new(@csv_object),
        filename: "insurance_account_transactions.csv",
        content_type: "text/csv"
      )

      @file_repository.save!
    end
  end
end
