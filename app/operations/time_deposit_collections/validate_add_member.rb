module TimeDepositCollections
  class ValidateAddMember < AppValidator
    def initialize(config:)
      super()

      @config                   = config
      @time_deposit_collection  = @config[:time_deposit_collection]
      @member                   = @config[:member]
      @lock_in_period           = @config[:lock_in_period]
      @amount                   = @config[:amount]
      @user                     = @config[:user]
    end

    def execute!
      if @time_deposit_collection.blank?
        @errors[:messages] << {
          key: "time_deposit_collection",
          message: "Record not found"
        }
      elsif @time_deposit_collection.not_pending?
        @errors[:messages] << {
          key: "time_deposit_collection",
          message: "Record not pending"
        }
      end

      if @member.blank?
        @errors[:messages] << {
          key: "member",
          message: "Member not found"
        }
      elsif @member.not_active?
        @errors[:messages] << {
          key: "member",
          message: "Member not active"
        }
      end

      if @time_deposit_collection.present? && @member.present?
        if @time_deposit_collection.member_ids.include?(@member.id)
          @errors[:messages] << {
            key: "member",
            message: "Member already has pending transaction"
          }
        end
      end

      if @amount.blank?
        @errors[:messages] << {
          key: "amount",
          message: "Amount not found"
        }
      elsif @amount <= 0
        @errors[:messages] << {
          key: "amount",
          message: "Invalid amount #{@amount}"
        }
      end

      if @lock_in_period.blank?
        @errors[:messages] << {
          key: "lock_in_period",
          message: "Lock in period not found"
        }
      end

      #not_yet_implemented!

      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }

      @errors
    end
  end
end
