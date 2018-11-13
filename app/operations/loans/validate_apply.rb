module Loans
  class ValidateApply < AppValidator
    def initialize(config:)
      super()
  
      @config       = config
      @loan_product = @config[:loan_product]
      @member       = @config[:member]
      @user         = @config[:user]
    end

    def execute!
      if @loan_product.blank?
        @errors[:messages] << {
          key: "loan_product",
          message: "loan product not found"
        }
      end

      if @member.blank?
        @errors[:messages] << {
          key: "member",
          message: "member not found"
        }
      elsif !@member.active?
        @errors[:messages] << {
          key: "member",
          message: "member is not active"
        }
      end

      if @loan_product.present? and @member.present?
        if Loan.active_or_pending.where(member_id: @member.id, loan_product_id: @loan_product.id).count > 0
          @errors << {
            key: "loan_product",
            message: "member still has active loan for this product"
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
