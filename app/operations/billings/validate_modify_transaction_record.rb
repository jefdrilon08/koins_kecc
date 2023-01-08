module Billings
  class ValidateModifyTransactionRecord < AppValidator
    def initialize(config:)
      @config               = config
      @billing              = @config[:billing]
      @current_transaction  = @config[:current_transaction]
      @current_member       = @config[:current_member]
      @user                 = @config[:user]
      @branch               = @billing.branch

      super()
    end

    def execute!
#      is_cutoff = ::Utils::IsCutoff.new(branch: @branch).execute!
#
#      if is_cutoff
#        @errors[:messages] << {
#          key: "cut_off",
#          message: "Within cutoff period"
#        }
#      end

      # Validate billing status
      if @billing.blank?
        @errors[:messages] << {
          key: "billing",
          message: "Billing not found"
        }
      elsif !@billing.pending?
        @errors[:messages] << {
          key: "billing",
          message: "Status is not pending"
        }
      end

      # Validate presence of current_transaction
      if @current_transaction.blank?
        @errors[:messages] << {
          key: "current_transaction",
          message: "current_transaction not found"
        }
      end

      # Validate presence of current_member
      if @current_member.blank?
        @errors[:messages] << {
          key: "current_member",
          message: "current_member not found"
        }
      end

      # Validate user
      if @user.blank?
        @errors[:messages] << {
          key: "user",
          message: "user not found"
        }
      else
      end

      # Validate current_transaction
      if @current_transaction.present?
        amount  = @current_transaction[:amount].try(:to_f)
 
        if amount < 0
          @errors[:messages] << {
            key: "amount",
            message: "Amount cannot be negative"
          }
        end
      end

      # Check record_type
      if @billing.present? and @billing.pending? and @current_transaction.present? and @current_member.present?
        if @current_transaction[:record_type] == "SAVINGS"
          validate_savings!
        elsif @current_transaction[:record_type] == "WP"
          validate_wp!
        elsif @current_transaction[:record_type] == "INSURANCE"
          validate_insurance!
        elsif @current_transaction[:record_type] == "EQUITY"
          validate_equity!
        elsif @current_transaction[:record_type] == "LOAN_PAYMENT"
          validate_loan_payment!
        else
          @errors[:messages] << {
            key: "record_type",
            message: "invalid record_type #{@current_transaction[:record_type]}"
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

    def validate_loan_payment!
      loan  = ReadOnlyLoan.where(id: @current_transaction[:loan_id]).first
      
      if loan.blank?
        @errors[:messages] << {
          key: "loan",
          message: "loan not found"
        }
      elsif !loan.active?
        @errors[:messages] << {
          key: "loan",
          message: "loan is not active"
        }
      else
        loan_payment    = @current_transaction[:amount].try(:to_f)
        
        current_balance = loan.total_balance.to_f
        
        if loan_payment > current_balance
          @errors[:messages] << {
            key: "loan",
            message: "overpayment of #{loan_payment} > current_balance: #{current_balance}"
          }
        end
      end
    end

    def fetch_wp_amount!
      wp_amount = 0.00

      @billing.data.with_indifferent_access[:records].each do |r|
        if r[:member][:id] == @current_member[:id]
          r[:records].each do |rr|
            if rr[:record_type] == "WP"
              wp_amount = rr[:amount].try(:to_f)
            end
          end
        end
      end

      wp_amount
    end

    def fetch_loan_payment_amount!
      loan_payment_amount = 0.00

      @billing.data.with_indifferent_access[:records].each do |r|
        if r[:member][:id] == @current_member[:id]
          r[:records].each do |rr|
            if rr[:record_type] == "LOAN_PAYMENT"
              loan_payment_amount += rr[:amount].try(:to_f)
            end
          end
        end
      end

      loan_payment_amount
    end

    def validate_insurance!
      member_account  = MemberAccount.insurance.where(id: @current_transaction[:member_account_id]).first

      if member_account.blank?
        @errors[:messages] << {
          key: "member_account",
          message: "member_account for insurance payment not found"
        }
      end
    end
    
    def validate_equity!
      member_account  = MemberAccount.equities.where(id: @current_transaction[:member_account_id]).first

      if member_account.blank?
        @errors[:messages] << {
          key: "member_account",
          message: "member_account for equity payment not found"
        }
      end
    end

    def validate_wp!
      member_account  = ReadOnlyMemberAccount.savings.where(id: @current_transaction[:member_account_id]).first
      amount          = @current_transaction[:amount].try(:to_f)
    
#      if member_account.member.loans.active.count == 0
#        @errors[:messages] << {
#          key: "wp",
#          message: "Cannot withdraw payment for no active loans"
#        }
#      end

      if member_account.blank?
        @errors[:messages] << {
          key: "member_account",
          message: "member_account for withdraw payment not found"
        }
      elsif member_account.balance.to_f - amount < member_account.maintaining_balance
        @errors[:messages] << {
          key: "member_account",
          message: "not enough funds to withdraw #{amount}. Balance: #{member_account.balance}. Maintaning balance: #{member_account.maintaining_balance}"
        }
      end
    end

    def fetch_total_loan_balances!
      balance = 0.00

      @billing.data.with_indifferent_access[:records].each do |r|
        if r[:member][:id] == @current_member[:id]
          r[:records].each do |rr|
            if rr[:record_type] == "LOAN_PAYMENT"
              loan = Loan.active.where(id: rr[:loan_id]).first

              if loan
                balance += loan.total_balance
              end
            end
          end
        end
      end

      balance
    end

    def validate_savings!
      member_account  = ReadOnlyMemberAccount.savings.where(id: @current_transaction[:member_account_id]).first

      if member_account.blank?
        @errors[:messages] << {
          key: "member_account",
          message: "member_account for desosit not found"
        }
      end
    end
  end
end
