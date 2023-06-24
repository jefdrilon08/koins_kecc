module Kmba
  class SavePayment
     attr_accessor :member

    def initialize(payment_data:)
      super()
      @payment_data = payment_data
    end

    def execute!
      @rf_or_lif = MemberAccount.where(id: @payment_data[:subsidiary_id])
      if @rf_or_lif.count > 0
        payment_data = AccountTransaction.new(
          subsidiary_id: @payment_data[:subsidiary_id],
          subsidiary_type: @payment_data[:subsidiary_type],
          amount: @payment_data[:amount],
          transaction_type: @payment_data[:transaction_type],
          transacted_at: @payment_data[:transacted_at],
          status: @payment_data[:status],
          data: @payment_data[:data],
          created_at: @payment_data[:created_at],
          updated_at: @payment_data[:updated_at],
        )
      end

      Rails.logger.info(puts " New Record is Save ID NO : #{@payment_data[:subsidiary_id]}, saved! ")
      payment_data.save!
      ::MemberAccounts::Rehash.new( member_account:MemberAccount.find(@payment_data[:subsidiary_id])).execute!
    end
  end
end
