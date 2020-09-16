module Loans
  class ValidateRestructure < AppValidator
    def initialize(config:)
      super()

      @config = config

      @user                      = @config[:user]
      @co_maker                  = @config[:co_maker]
      @co_maker_member           = @config[:co_maker_member]
      @loan_product              = @config[:loan_product]
      @member                    = @config[:member]
      @pn_number                 = @config[:pn_number]
      @clip_number               = @config[:clip_number]
      @date_prepared             = @config[:date_prepared]
      @num_installments          = @config[:num_installments].try(:to_i)
      @term                      = @config[:term]
      @active_loans              = @config[:active_loans]
      @beneficiary_first_name    = @config[:beneficiary_first_name]
      @beneficiary_middle_name   = @config[:beneficiary_middle_name]
      @beneficiary_last_name     = @config[:beneficiary_last_name]
      @beneficiary_date_of_birth = @config[:beneficiary_date_of_birth]
      @beneficiary_relationship  = @config[:beneficiary_relationship]
    end

    def execute!
      if @pn_number.blank?
        @errors[:messages] << {
          key: "pn_number",
          message: "pn_number required"
        }
      elsif Loan.where(pn_number: @pn_number).count > 0
        @errors[:messages] << {
          key: "pn_number",
          message: "pn_number already taken"
        }
      end

      if @clip_number.blank?
        @errors[:messages] << {
          key: "clip_number",
          message: "clip_number required"
        }
      end

      if @loan_product.blank?
        @errors[:messages] << {
          key: "loan_product",
          message: "loan_product required"
        }
      end

      if @active_loans.blank?
        @errors[:messages] << {
          key: "active_loans",
          message: "active_loans required"
        }
      end

      if @active_loans.any? and @loan_product.present?
        if @active_loans.pluck(:loan_product_id).include?(@loan_product.id)
          @errors[:messages] << {
            key: "loan_product",
            message: "invalid loan product for restructuring"
          }
        end
      end

      if @member.member_type == "Regular"
        if @co_maker.blank?
          @errors[:messages] << {
            key: "co_maker",
            message: "co_maker required"
          }
        end

        if @co_maker_member.blank?
          @errors[:messages] << {
            key: "co_maker_member",
            message: "co_maker_member required"
          }
        end
      end

      if @member.blank?
        @errors[:messages] << {
          key: "member",
          message: "member required"
        }
      end

      if @beneficiary_first_name.blank?
        @errors[:messages] << {
          key: "beneficiary_first_name",
          message: "beneficiary_first_name required"
        }
      end

      if @beneficiary_last_name.blank?
        @errors[:messages] << {
          key: "beneficiary_last_name",
          message: "beneficiary_last_name required"
        }
      end

      if @beneficiary_date_of_birth.blank?
        @errors[:messages] << {
          key: "beneficiary_date_of_birth",
          message: "beneficiary_date_of_birth required"
        }
      end

      if @beneficiary_relationship.blank?
        @errors[:messages] << {
          key: "beneficiary_relationship",
          message: "beneficiary_relationship required"
        }
      end

      # Do not allow creation of restructured loan if there are still existin restructured loans
      if @member.present? and @loan_product.present?
        if Loan.where(is_restructured: true, status: 'pending', member_id: @member.id).count > 0
          @errors[:messages] << {
            key: "loan",
            message: "member still has pending restructured loan"
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
