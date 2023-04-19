module Kmba
  class UpdatePayments
     attr_accessor :member

    def initialize(payment_data:)
      super()
      @payment_data = payment_data
    raise @payment_data.inspect
    end

    def execute!
      @payment = AccountTransaction.where(subsidiary_id: @payment_data[:subsidiary_id])
      @payment.update!(
        subsidiary_id: @payment_data[:subsidiary_id],
        subsidiary_type: @payment_data[:subsidiary_type],
        amount: @payment_data[:amount],
        transaction_type: @payment_data[:transaction_type],
        transacted_at: @payment_data[:transacted_at],
        status: @payment_data[:status],
        data: @payment_data[:data],
        created_at: @payment_data[:created_at],
        updated_at: @payment_data[:updated_at]
      )

    raise @payment.inspect
    Rails.logger.info(puts "Update Record Subsidiary ID NO : #{@payment_data[:subsidiary_id]}, updated! ")
    end
  end
end
