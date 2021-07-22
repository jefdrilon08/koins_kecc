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
      # query!

      # @account_transactions = @result

      cmd = Exports::GenerateAccountTransactionsCsv.new(
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
                    account_transactions.id AS transaction_id,
                    account_transactions.transacted_at,
                    COALESCE(account_transactions.data->>'ending_balance', '0.00')::float AS balance,
                    member_accounts.id AS member_account_id,
                    member_accounts.account_type,
                    member_accounts.account_subtype,
                    COALESCE(member_accounts.balance, '0.00')::float AS ma_balance,
                    members.data->>'recognition_date' AS recognition_date,
                    members.id AS member_id,
                    members.member_type,
                    members.status,
                    members.insurance_status,
                    members.insurance_date_resigned
                  FROM
                    account_transactions
                  LEFT JOIN
                    member_accounts ON member_accounts.id = account_transactions.subsidiary_id
                  LEFT JOIN
                    members ON members.id = member_accounts.member_id
                  WHERE
                    account_transactions.transacted_at BETWEEN '#{@start_date}' AND '#{@end_date}' 
                    AND member_accounts.account_type = 'INSURANCE' 
                    AND members.insurance_status IN ('inforce', 'lapsed', 'dormant')
                  GROUP BY
                    transaction_id,
                    member_account_id,
                    recognition_date,
                    members.id
                  ORDER BY
                    account_transactions.id, account_transactions.transacted_at DESC
                EOS
    end
  end
end
