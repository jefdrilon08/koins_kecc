module Loans
  class ValidateApprove < AppValidator
    def initialize(config:)
      super()

      @loan = config[:loan]
      @user = config[:user]

      @valid_roles  = ::Users::FetchValidRoles.new(
                        module_name: "approve_loan"
                      ).execute!
    end

    def execute!
      if @loan.blank?
        @errors[:messages] << {
          key: "loan",
          message: "Loan not found"
        }
      elsif !@loan.pending?
        @errors[:messages] << {
          key: "loan",
          message: "Loan not pending"
        }
      end

      if @user.blank?
        @errors[:messages] << {
          key: "user",
          message: "User not found"
        }
      elsif @user.current_loans.intersection(@valid_roles).size == 0
        @errors[:messages] << {
          key: "user",
          message: "unauthorized"
        }
      end

      if @loan.present?
        validate_accounting_entry!
        validate_parameters!
        validate_amortization!

        if !@loan.restructured? and !@loan.application_form.attached?
          @errors[:messages] << {
            key: "application_form",
            message: "Application form not attached"
          }
        end
      end

      #not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end

    private

    def validate_amortization!
      if @loan.amortization_schedule_entries.where("principal < 0.00 OR interest < 0.00").count > 0
        @errors[:messages] << {
          key: "amortization",
          message: "Invalid amortization detected"
        }
      end
    end

    def validate_parameters!
      # First date of payment
      if @loan.first_date_of_payment.blank?
        @errors[:messages] << {
          key: "first_date_of_payment",
          message: "First date of payment required"
        }
      end

      # Date released
      if @loan.date_released.blank?
        @errors[:messages] << {
          key: "date_released",
          message: "Date released required"
        }
      end
    end

    def validate_accounting_entry!
      if @loan.present?
        accounting_entry_data = @loan.data.with_indifferent_access[:accounting_entry]

        dr_amount = 0.00
        cr_amount = 0.00

        accounting_entry_data[:journal_entries].each do |o|
          if o[:post_type] == "DR"
            dr_amount += o[:amount].to_f.round(2)
          end

          if o[:post_type] == "CR"
            cr_amount += o[:amount].to_f.round(2)
          end
        end

        dr_amount = dr_amount.round(2)
        cr_amount = cr_amount.round(2)

        if dr_amount != cr_amount
          @errors[:messages] << {
            key: "accounting_entry",
            message: "Accounting entry not balanced. DR: #{dr_amount} CR: #{cr_amount}"
          }
        end
      end
    end
  end
end
