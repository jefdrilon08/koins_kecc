module MemberAccountValidations
  class ValidateMemberAccountValidationForApproval < AppValidator
    attr_accessor :errors

    def initialize(config:)
     super()

      @config = config
      @member_account_validation = @config[:member_account_validation]
      @branch = @member_account_validation.branch
    end

    def execute!
      # check_params!
      # validate_accounting_entry!

      if @branch.nil?
        @errors[:messages] << {
          key: "member",
          message: "Branch cant be blank."
        }
      end

      if @member_account_validation.date_prepared.nil?
        @errors[:messages] << {
          key: "member",
          message: "Date Prepared cant be blank."
        }  
      end

      if @member_account_validation.data.with_indifferent_access[:accounting_entry].present?
        accounting_entry_data = @member_account_validation.data.with_indifferent_access[:accounting_entry]

        dr_amount = 0.00
        cr_amount = 0.00

        if accounting_entry_data[:journal_entries].any?
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
        else
          @errors[:messages] << {
            key: "accounting_entry",
            message: "No journal entries found for accounting entry"
          }
        end
      end

      #not_yet_implemented!

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors
    end

    private

    def check_params!
      if @branch.nil?
        @errors[:messages] << {
          key: "member",
          message: "Branch cant be blank."
        }
      end

      if @member_account_validation.date_prepared.nil?
        @errors[:messages] << {
          key: "member",
          message: "Date Prepared cant be blank."
        }  
      end
    end

    def validate_accounting_entry!
      accounting_entry_data = @member_account_validation.data.with_indifferent_access[:accounting_entry]

      dr_amount = 0.00
      cr_amount = 0.00

      if accounting_entry_data[:journal_entries].any?
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
      else
        @errors[:messages] << {
          key: "accounting_entry",
          message: "No journal entries found for accounting entry"
        }
      end
    end
  end
end
