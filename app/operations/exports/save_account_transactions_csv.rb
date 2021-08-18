module Exports
  class SaveAccountTransactionsCsv
    attr_accessor :start_date, :end_date, :file_repository, :csv_object, :account_transactions

    def initialize(start_date:, end_date:)
      @start_date = start_date.try(:to_date) 
      @end_date   = end_date.try(:to_date)

      if @start_date.blank? or @end_date.blank?
        raise "Invalid parameters"
      end

      # @member_accounts      = MemberAccount.insurance
      # @account_transactions = AccountTransaction.where(
      #                           "Date(account_transactions.updated_at) >= ? AND Date(account_transactions.updated_at) <= ? AND subsidiary_id IN (?)", 
      #                           @start_date, 
      #                           @end_date, 
      #                           @member_accounts.pluck(:id)
      #                         )
    end

    def execute!
      query!

      @account_transactions = @result

      cmd = Exports::GenerateAccountTransactionsCsvFromSql.new(
              account_transactions: @account_transactions
            )

      @csv_object = cmd.execute!

      @file_repository  = FileRepository.new(
                            file_type: "ACCOUNT_TRANSACTIONS"
                          )

      @file_repository.file.attach(
        io: StringIO.new(@csv_object),
        filename: "account_transactions.csv",
        content_type: "text/csv"
      )

      @file_repository.save!
    end

    def query!
      @result  = ActiveRecord::Base.connection.execute(<<-EOS).to_a
                  SELECT DISTINCT ON(account_transactions.id)
                    account_transactions.id AS at_id,
                    account_transactions.subsidiary_id AS subsidiary_id,
                    account_transactions.subsidiary_type AS subsidiary_type,
                    COALESCE(account_transactions.amount, '0.00')::float AS amount,
                    account_transactions.transaction_type AS transaction_type,
                    account_transactions.transacted_at AS transacted_at,
                    account_transactions.status AS status,
                    account_transactions.data AS at_data,
                    account_transactions.created_at AS created_at,
                    account_transactions.updated_at AS updated_at
                  FROM
                    account_transactions
                  LEFT JOIN
                    member_accounts ON member_accounts.id = account_transactions.subsidiary_id
                  LEFT JOIN
                    members ON members.id = member_accounts.member_id
                  WHERE
                    account_transactions.updated_at >= '#{@start_date}' 
                    AND account_transactions.updated_at <= '#{@end_date}'
                    AND member_accounts.account_type = 'INSURANCE' 
                    AND members.insurance_status IN ('inforce', 'lapsed', 'dormant', 'resigned')
                  GROUP BY
                    at_id
                  ORDER BY
                    account_transactions.id, account_transactions.transacted_at DESC
                EOS
    end
  end
end
