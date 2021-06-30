module Loans
  class ValidateRemoteApply < AppValidator
    attr_accessor :errors

    def initialize(config:)
      super()

      @config = config

      @member           = @config[:member]
      @loan_product     = @config[:loan_product]
      @co_maker_one     = @config[:co_maker_one]
      @co_maker_two     = @config[:co_maker_two]
      @amount           = @config[:amount]
      @term             = @config[:term]
      @num_installments = @config[:num_installments]
    end

    def execute!
      if @term.blank?
        @errors[:messages] << {
          key: "term",
          message: "term required"
        }
      end

      if @num_installments.blank?
        @errors[:messages] << {
          key: "num_installments",
          message: "num_installments required"
        }
      end

#      if @co_maker_one.blank?
#        @errors[:messages] << {
#          key: "co_maker_one",
#          message: "co_maker_one required"
#        }
#      end
#
#      if @co_maker_two.blank?
#        @errors[:messages] << {
#          key: "co_maker_two",
#          message: "co_maker_two required"
#        }
#      end

      if @loan_product.blank?
        @errors[:messages] << {
          key: "loan_product",
          message: "Loan product not found"
        }
      end

      if @member.blank?
        @errors[:messages] << {
          key: "member",
          message: "Member not found"
        }
      end

      if @loan_product.present? and @member.present?
        loans = Loan.select(
                  "id, status, member_id"
                ).where(
                  status: ["pending", "active", "processing", "for-verification"], 
                  member_id: @member.id,
                  loan_product_id: @loan_product.id
                )

        if loans.any?
          @errors[:messages] << {
            key: "loans",
            message: "Member still has existing loan for #{@loan_product.name}"
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
