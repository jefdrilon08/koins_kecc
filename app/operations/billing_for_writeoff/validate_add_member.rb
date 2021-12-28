module BillingForWriteoff
    class ValidateAddMember < AppValidator
      def initialize(config:)
        super()

        @config               = config
        @billing_for_writeoff = @config[:billing_for_writeoff]
        @loan_product_id      = @config[:loan_product_id]
        @member               = @config[:member]
        @loan_id              = Loan.where(loan_product_id: @loan_product_id,member_id: @member.id,status:"active").pluck(:id)
        @amount               = @config[:amount].to_f.round(2)        
        
      end

      def execute!
        
        if @billing_for_writeoff.blank?
          @errors[:messages] << {
            key: "billing_for_writeoff",
            message: "Billing For Writeoff Not Found"
          }
        end

        if @member.blank?
           @errors[:messages] << {
            key: "member",
            message: "member not found"
          }
        end

        if @member.present?
          billing_record = @billing_for_writeoff.data.with_indifferent_access[:record]
          billing_record.each do |b|
            if  b[:member]["id"] == @member.id  and b[:loan]["loan_product_id"] == @loan_product_id
                @errors[:messages] << {
                key: "member_record",
                message: "duplicate member and loan record"
                }
            end
          end
        end




        if @loan_product_id.present? and @loan_id.empty?
          @errors[:messages] << {
            key: "member loan product",
            message: "Member Loan not found"
          }
        elsif @loan_product_id.present? and @loan_id.present?
            loan = Loan.find(@loan_id.shift) 
            if @amount.present? and @amount  == 0.0 
              @errors[:messages] << {
                key: "amount",
                message: "amount cannot be zero"
              }

            elsif  @amount.present? and @amount > loan.principal_balance.to_f.round(2)
              @errors[:messages] << {
                key: "check_amount",
                message: "amount is greather than loan principal balance #{loan.principal_balance}"
              }
            end
         end
        #not_yet_implemented!

        @errors[:messages].each do |o|
          @errors[:full_messages] << o[:message]
        end

        @errors
      end
   
  end
end
