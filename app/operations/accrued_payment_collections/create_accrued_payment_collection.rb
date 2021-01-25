module AccruedPaymentCollections
  class CreateAccruedPaymentCollection
    def initialize(config:)
      @config           = config
      @collection_date  = @config[:collection_date].try(:to_date) || Date.today
      @user             = @config[:user]
      @branch           = @config[:branch_id]
      @center           = @config[:center_id]

      @accrued_billing  = AccruedBilling.new(
                                          collection_date: @collection_date,
                                          branch_id: @branch,
                                          center_id: @center,
                                          status: 'pending',
                                          data: {
                                            loans:[]
                                          }
                                        )

    end

    def execute!
      process_accrued_data!
      @accrued_billing.save!
      @accrued_billing
    end

    def process_accrued_data!
    
      @l_ids  = []
      l_id = Loan.where(center_id: @center).ids
      l_id.each do |l|
        a = Loan.find(l)
        a_data = a.data.with_indifferent_access
        if a_data[:accrued_interest].present?
          laman = a.id
          lp = LoanProduct.find(a.loan_product_id)
          @l_ids << laman
        end
      end
      @l_ids.each do |al|
        loan = Loan.find(al)
        amount = loan.data['accrued_interest']['total_accrued_interest'] - loan.data['accrued_interest']['total_accrued_interest_balance']
        @accrued_billing.data['loans'] << {
          id: loan.id,
          amount: amount,   
          member: {
                  id: loan.member.id,
                  first_name: loan.member.first_name,
                  last_name: loan.member.last_name,
                  middle_name: loan.member.middle_name,
                  identification_number: loan.member.identification_number,
                  center: loan.center.name
                }
        }
      end   
    end

  end
end
