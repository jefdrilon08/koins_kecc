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
                                            headers:[],
                                            records:[]
                                          }
                                        )

    end

    def execute!
      process_accrued_data!
      @accrued_billing.save!
      @accrued_billing
    end

    def process_accrued_data!
      @header = []
      dta = Member.joins(:loans).where("members.center_id = '844264f4-a566-4ca7-89a1-39278dbd183f' and loans.data ->> 'accrued_interest' IS NOT NULL" , @center)   
      dta.each do |dt|
        loan = dt.loans.ids
        loan.each do |l|
          @header << Loan.find(l).loan_product.name
        end
      end
      @header.uniq.each do |hd|
        @accrued_billing.data['headers'] << {
          name: hd
        }
      end
    end

  end
end
