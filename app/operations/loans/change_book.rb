module Loans
  class ChangeBook
    def initialize(config:)
      @loan = config[:loan]
      @book = config[:book]
      @user = config[:user]
    end

    def execute!
      data  = @loan.data.with_indifferent_access

      data[:accounting_entry][:book]  = @book

      @loan.update!(data: data)

      @loan
    end
  end
end
