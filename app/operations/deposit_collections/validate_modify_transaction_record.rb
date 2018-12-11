module DepositCollections
  class ValidateModifyTransactionRecord < AppValidator
    def initialize(config:)
      @config               = config
      @deposit_collection   = @config[:deposit_collection]
      @current_transaction  = @config[:current_transaction]
      @current_member       = @config[:current_member]
      @user                 = @config[:user]

      super()
    end

    def execute!
      # Validate deposit_collection status
      if @deposit_collection.blank?
        @errors[:messages] << {
          key: "deposit_collection",
          message: "DepositCollection not found"
        }
      elsif !@deposit_collection.pending?
        @errors[:messages] << {
          key: "deposit_collection",
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

      #not_yet_implemented!

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors
    end

    private
  end
end
