module Adjustments
  module RecomputeRestructures
    class Create

      def initialize(config:)
        @config = config
        @branch_id = @config[:branch_id] 
        @center_id = @config[:center_id]
        @member_id = @config[:member_id]
        @member_loans = Loan.joins(:member).where("loans.member_id = ? and loans.loan_product_id = ?", @member_id, "1c2fcdbd-d60b-402c-b04b-824bb90958d1").last
      end
      def execute!
        @loans =  {
          loan: @member_loans
          }
        loans_recompute = ::Loans::RecomputeRestructure.new(config: @loans).execute!
        
        #raise loans_recompute.inspect
        
        
        @rrest = RecomputeRestructure.new(
                               branch: @branch_id,
                               center: @center_id,
                               member: @member_id,
                               loan: @member_loans.id,
                               status: "pending",
                               data: {
                                  loans: []
                               }

                                          )

        
        @rrest.data["loans"] << loans_recompute

        @rrest.save!


        @rrest
        

        
      end

    end
  end
end
