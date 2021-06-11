module AccruedPaymentCollections
  class CreateAccruedPaymentCollection
    def initialize(config:)
      @config           = config
      @collection_date  = @config[:collection_date].try(:to_date) || Date.today
      @user             = @config[:user]
      @branch           = @config[:branch_id]
      @center           = @config[:center_id]
      @member           = @config[:member_id]


      @accrued_billing  = AccruedBilling.new(
                                          collection_date: @collection_date,
                                          branch_id: @branch,
                                          center_id: @center,
                                          member_id: @member,
                                          status: 'pending',
                                          data: {
                                            member_data:[],
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
      @record = []
      dta = Loan.where("center_id = ? and loans.data ->> 'accrued_interest' IS NOT NULL" , @center)   
      dta.pluck(:loan_product_id).uniq.each do |dt|
        @header << LoanProduct.find(dt)
      end
      @header.uniq.each do |hd|
        @accrued_billing.data['headers'] << {
          name: hd.name,
          id:   hd.id
      }
      end
      
      dta.pluck(:member_id).uniq.each do |rec|
         
          @accrued_billing.data['member_data'] << {  
            member_id: rec,
            name:      Member.find(rec).full_name,
            loan_data: []
          }
      end

      @accrued_billing.data['member_data'].each do |ld|
         @header.each do |hd|
          l = Loan.where("member_id = ? and loan_product_id = ? and data ->> 'accrued_interest' IS NOT NULL" , ld[:member_id] , hd.id ).ids.last 
          if l.nil?
          else 
            x = Loan.find(l)
            amt = x.data['accrued_interest']['total_accrued_interest'] - x.data['accrued_interest']['total_accrued_interest_balance']
          end
          if x.present?
            ld[:loan_data] << { 
              name:     hd.name,
              loan_id:  x.id,
              amount:   amt

            }
          else
            ld[:loan_data] << { 
              name:     hd.name,
              loan_id:  'false',
              amount:   'false'                   
            }
          end
        end
      end
    end

  end
end
