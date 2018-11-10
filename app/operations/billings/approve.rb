module Billings
  class Approve
    def initialize(config:)
      @config   = config
      @billing  = @config[:billing]
      @user     = @config[:user]

      @data = @billing.try(:data).try(:with_indifferent_access)

      @data_loan_payments     = @billing.loan_payments
      @data_deposits          = @billing.deposits
      @data_insurance         = @billing.insurance
      @data_withdraw_payments = @billing.withdraw_payments
      @data_accounting_entry  = @billing.accounting_entry
    end

    def execute!
      process_loan_payments!
      process_savings!
      process_insurance!
      post_accounting_entry!

      @data[:approved_by] = @user.full_name

      @billing.update!(
        status: "approved",
        data: @data
      )

      @billing
    end

    private

    def process_loan_payments!
      @data_loan_payments.each do |o|
        config  = {
          loan_payment: o,
          date_paid: @billing.collection_date,
          user: @user,
          particular: @data_accounting_entry[:particular]
        }

        ::Billings::ApproveLoanPaymentHash.new(
          config: config
        ).execute!
      end
    end

    def process_savings!
      @data_deposits.each do |o|
        config  = {
          date_paid: @billing.collection_date,
          deposit: o,
          user: @user,
          particular: @data_accounting_entry[:particular]
        }

        ::Billings::ApproveSavingsDepositHash.new(
          config: config
        ).execute!
      end
    end

    def process_insurance!
      @data_insurance.each do |o|
        config  = {
          date_paid: @billing.collection_date,
          insurance_deposit: o,
          user: @user,
          particular: @data_accounting_entry[:particular]
        }

        ::Billings::ApproveInsuranceDepositHash.new(
          config: config
        ).execute!
      end
    end

    def post_accounting_entry!
    end
  end
end
