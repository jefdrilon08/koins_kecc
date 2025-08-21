module Loans
  class ValidateSave < AppValidator
    def initialize(config:)
      super()

      @config       = config
      @loan_data    = @config[:loan_data]
      @user         = @config[:user]
      @loan_product = LoanProduct.where(id: @loan_data[:loan_product_id]).first
      @member       = Member.where(id: @loan_data[:member_id]).first
    end

    def execute!
      #PROJECT TYPE present in entry point
      # if @loan_product.is_entry_point == true and @loan_data[:project_type_id].blank?
      # #if @loan_product.is_entry_point == true
      #   @errors[:messages] << {
      #     key: "project_type",
      #     message: "Project Type is required"
      #   }
      # end
      # PN Number: present, unique
      if @loan_data[:pn_number].blank?
        @errors[:messages] << {
          key: "pn_number",
          message: "PN Number required"
        }
      else
        if @loan_data[:id].blank? and Loan.where(pn_number: @loan_data[:pn_number]).count > 0
          @errors[:messages] << {
            key: "pn_number",
            message: "PN Number already taken"
          }
        elsif Loan.where(pn_number: @loan_data[:pn_number]).where.not(id: @loan_data[:id]).count > 0
          @errors[:messages] << {
            key: "pn_number",
            message: "PN Number already taken"
          }
        end
      end

      # Principal
      if @loan_data[:principal].blank?
        @errors[:messages] << {
          key: "principal",
          message: "Principal amount required"
        }
      elsif @loan_data[:principal].try(:to_f) <= 0
        @errors[:messages] << {
          key: "principal",
          message: "Principal amout must be a positive number"
        }
      end

      # Loan product
      # Existing loans
      if @loan_product.blank?
        @errors[:messages] << {
          key: "loan_product",
          message: "Loan product not found"
        }
      elsif Loan.pending.where.not(id: @loan_data[:id]).where(member_id: @loan_data[:member_id], loan_product_id: @loan_product.id).count > 0
        @errors[:messages] << {
          key: "loan_product",
          message: "Member still has pending loan products"
        }
      end

      # Voucher particular
      if @loan_data[:data][:voucher][:bank_check_number].blank?
        @errors[:messages] << {
          key: "voucher.bank_check_number",
          message: "Voucher Bank Check Number required"
        }
      elsif @loan_data[:data][:voucher][:check_number].blank?
        @errors[:messages] << {
          key: "voucher.check_number",
          message: "Voucher Check Voucher Number required"
        }
      elsif @loan_data[:data][:voucher][:date_requested].blank?
        @errors[:messages] << {
          key: "voucher.date_requested",
          message: "Voucher Date Requested required"
        }
      elsif @loan_data[:data][:voucher][:date_of_check].blank?
        @errors[:messages] << {
          key: "voucher.date_of_check",
          message: "Voucher Date of Check required"
        }
      end

      #not_yet_implemented!

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors
    end
  end
end
