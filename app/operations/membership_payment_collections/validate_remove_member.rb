module MembershipPaymentCollections
  class ValidateRemoveMember < AppValidator
    def initialize(config:)
      super()

      @config                         = config
      @membership_payment_collection  = @config[:membership_payment_collection]
      @member                         = @config[:member]
      @user                           = @config[:user]
    end

    def execute!
      if @membership_payment_collection.blank?
        @errors[:messages] << {
          key: "membership_payment_collection",
          message: "Record not found"
        }
      elsif @membership_payment_collection.not_pending?
        @errors[:messages] << {
          key: "membership_payment_collection",
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

      if @membership_payment_collection.present? && @member.present?
        if !@membership_payment_collection.member_ids.include?(@member.id)
          @errors[:messages] << {
            key: "member",
            message: "Member not included in records"
          }
        end
      end

      #not_yet_implemented!

      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }

      @errors
    end
  end
end
