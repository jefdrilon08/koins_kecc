module InsuranceFundTransferCollections
  class ValidateAddMember < AppValidator
    def initialize(config:)
      super()

      @config                              = config
      @insurance_fund_transfer_collection  = @config[:insurance_fund_transfer_collection]
      @member                              = @config[:member]
      @user                                = @config[:user]
    end

    def execute!
      if @insurance_fund_transfer_collection.blank?
        @errors[:messages] << {
          key: "insurance_fund_transfer_collection",
          message: "Record not found"
        }
      elsif @insurance_fund_transfer_collection.not_pending?
        @errors[:messages] << {
          key: "insurance_fund_transfer_collection",
          message: "Record not pending"
        }
      end

      if @member.blank?
        @errors[:messages] << {
          key: "member",
          message: "Member not found"
        }
      end

      if @insurance_fund_transfer_collection.present? && @member.present?
        if @insurance_fund_transfer_collection.member_ids.include?(@member.id)
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
