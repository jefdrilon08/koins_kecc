module Loans
  class ValidateSave < AppValidator
    def initialize(config:)
      super()

      @config       = config
      @loan_data    = @config[:loan_data]
      @user         = @config[:user]
      @loan_product = LoanProduct.where(id: @loan_data[:loan_product_id]).first
      @member       = Member.where(id: @loan_data[:member_id]).first
      @loan         = Loan.where(id: @loan_data[:id]).first if @loan_data[:id].present?

    end

    def execute!

      payload_mir = @loan_data[:monthly_interest_rate] || @loan_data.dig(:data, :monthly_interest_rate)

      Rails.logger.info(
        "[ValidateSave] loan_id=#{@loan&.id || 'NEW'} " \
        "member_id=#{@loan_data[:member_id]} " \
        "loan_product_id=#{@loan_product&.id} " \
        "payload_mir=#{payload_mir.inspect} " \
        "product_mir=#{@loan_product&.monthly_interest_rate.inspect} " \
        "product_non_teaching_mir=#{@loan_product&.non_teaching_monthly_interest_rate.inspect}"
      )
      
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
      
       active_loans = @loan_data[:paid_loans] || []
      if active_loans.present? && @loan.present?
        grand_total_paid = active_loans.map { |l| l[:total_paid].to_f }.sum
        if grand_total_paid >= @loan.principal.to_f
          @errors[:messages] << {
            key: "paid_loans",
            # message: "Active Loans Total (#{grand_total_paid}) is greater than loan principal (#{@loan.principal})"
            message:"Active loans total is greater than loan principal"
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
