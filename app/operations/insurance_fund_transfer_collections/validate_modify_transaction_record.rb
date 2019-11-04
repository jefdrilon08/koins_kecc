module InsuranceFundTransferCollections
  class ValidateModifyTransactionRecord < AppValidator
    def initialize(config:)
      @config                              = config
      @insurance_fund_transfer_collection  = @config[:insurance_fund_transfer_collection]
      @current_transaction                 = @config[:current_transaction]
      @current_member                      = @config[:current_member]
      @user                                = @config[:user]

      super()
    end

    def execute!
      # Validate fund_transfer_collection status
      if @insurance_fund_transfer_collection.blank?
        @errors[:messages] << {
          key: "insurance_fund_transfer_collection",
          message: "Insurancefund_transferCollection not found"
        }
      elsif !@insurance_fund_transfer_collection.pending?
        @errors[:messages] << {
          key: "insurance_fund_transfer_collection",
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
        else
          member_account  = MemberAccount.find(@current_transaction[:member_account_id])
          
          if member_account.blank?
            @errors[:messages] << {
              key: "account",
              message: "Account not found"
            }
          end
        end
      end

      #not_yet_implemented!

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors
    end

    private
  end
end
