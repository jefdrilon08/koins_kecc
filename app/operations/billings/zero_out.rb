module Billings
  class ZeroOut
    def initialize(config:)
      @config   = config
      @billing  = @config[:billing]
      @user     = @config[:user]

      @current_date = @config[:current_date] || Date.today

      @data = @billing.try(:data).try(:with_indifferent_access)

      @records  = @data[:records]
    end

    def execute!
      @records.each do |r|
        r[:records].each do |o|
          if o[:enabled] and o[:amount].to_f.round(2) > 0.00
            o[:amount]  = 0.00

            config  = {
              billing: @billing,
              current_transaction: o,
              current_member: r[:member],
              user: @user
            }

            ::Billings::ModifyTransactionRecord.new(
              config: config
            ).execute!
          end
        end
      end

      @billing
    end
  end
end
