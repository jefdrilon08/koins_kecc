module EquityWithdrawalCollections
  class ValidateAddMember < AppValidator
    def initialize(config:)
      super()

      @config                           = config
      @equity_withdrawal_collection     = @config[:equity_withdrawal_collection]
      @member                           = @config[:member]
      @user                             = @config[:user]
    end

    def execute!
      if @equity_withdrawal_collection.blank?
        @errors[:messages] << {
          key: "equity_withdrawal_collection",
          message: "Record not found"
        }
      elsif @equity_withdrawal_collection.not_pending?
        @errors[:messages] << {
          key: "equity_withdrawal_collection",
          message: "Record not pending"
        }
      end

      if @member.blank?
        @errors[:messages] << {
          key: "member",
          message: "Member not found"
        }
      end

      if @equity_withdrawal_collection.present? && @member.present?
        if @equity_withdrawal_collection.member_ids.include?(@member.id)
          @errors[:messages] << {
            key: "member",
            message: "Member already has pending transaction"
          }
        end
      end

      #not_yet_implemented!

      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }

      @errors
    end
  end
end
