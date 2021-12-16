module BillingForWriteoff
  class AddMember
      def initialize(config:)
        @config = config
        @config               = config
        @billing_for_writeoff = @config[:billing_for_writeoff]
        @member               = @config[:member]
        @loan_product_id      = @config[:loan_product_id]
        @loan_id              = Loan.where(loan_product_id: @loan_product_id,member_id: @member.id, status: "active").pluck(:id).shift
        @amount               = @config[:amount].to_f.round(2)    
        @loan                 = Loan.find(@loan_id)
        @data = @billing_for_writeoff.data.with_indifferent_access
      end

      def execute!

        record = {
          member: {
            id: @member.id,
            first_name: @member.first_name,
            last_name: @member.last_name,
            middle_name: @member.middle_name
          },
          center:{
            center_id: @member.center.id,
            center_name: @member.center.name
          },
          loan: {
            loan_id: @loan.id,
            loan_product_id: @loan_product_id,
            loan_name: LoanProduct.find(@loan_product_id).name,
            principal_balance: @loan.principal_balance.to_f.round(2),
            interest_balance: @loan.interest_balance.to_f.round(2),
            maturity_date: @loan.maturity_date
          },
          amount: @amount
        }
        @data[:record] << record
        @billing_for_writeoff.data = @data

        @data[:accounting_entry] = ::BillingForWriteoff::BuildAccountingEntry.new(config: {
          data: @data
        }).execute!
        @billing_for_writeoff.save!
      end
  end
end
