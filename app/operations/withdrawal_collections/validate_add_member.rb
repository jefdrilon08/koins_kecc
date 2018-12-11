module WithdrawalCollections
  class ValidateAddMember < AppValidator
    def initialize(config:)
      super()

      @config             = config
      @deposit_collection = @config[:deposit_collection]
      @member             = @config[:member]
      @user               = @config[:user]
    end

    def execute!
      if @deposit_collection.blank?
        @errors[:messages] << {
          key: "deposit_collection",
          message: "Record not found"
        }
      elsif @deposit_collection.not_pending?
        @errors[:messages] << {
          key: "deposit_collection",
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

      if @deposit_collection.present? && @member.present?
        if @deposit_collection.member_ids.include?(@member.id)
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
