module SavingsInsuranceTransferCollections
  class ValidateAddMember < AppValidator
    def initialize(config:)
      super()

      @config                                 = config
      @savings_insurance_transfer_collection  = @config[:savings_insurance_transfer_collection]
      @member                                 = @config[:member]
      @amount                                 = @config[:amount]

      @data = @savings_insurance_transfer_collection.try(:data).try(:with_indifferent_access)

      if @data.present?
        @savings_subtype    = @data[:savings_subtype]
        @insurance_subtype  = @data[:insurance_subtype]
      end
    end

    def execute!
      if @savings_insurance_transfer_collection.present? and !@savings_insurance_transfer_collection.pending?
        @errors[:messages] << {
          key: "savings_insurance_transfer_collection",
          message: "record is not pending"
        }
      end

      if @amount.blank?
        @errors[:messages] << {
          key: "amount",
          message: "Amount required"
        }
      end

      if @amount.present? and @amount <= 0.00
        @errors[:messages] << {
          key: "amount",
          message: "Amount should be positive"
        }
      end

      if @member.blank?
        @errors[:messages] << {
          key: "member",
          message: "Member required"
        }
      end

      if @member.present? and @savings_insurance_transfer_collection.member_ids.include?(@member.id)
        @errors[:messages] << {
          key: "message",
          message: "Member already included"
        }
      end

      if @member.present?
        @savings_account  = MemberAccount.where(member_id: @member.id, account_subtype: @savings_subtype).first

        if @savings_account.blank?
          @errors[:messages] << {
            key: "savings_account",
            message: "savings account #{@savings_subtype} not found"
          }
        end

        @insurance_account  = MemberAccount.where(member_id: @member.id, account_subtype: @insurance_subtype).first
        
        if @insurance_account.blank?
          @errors[:messages] << {
            key: "insurance_account",
            message: "insurance account #{@insurance_subtype} not found"
          }
        end
      end

      if @savings_account.present? and @savings_account.maintaining_balance < @amount
        @errors[:messages] << {
          key: "savings_account",
          message: "Not enough balance for savings #{@savings_subtype} (Maintaining balance: #{@savings_account.maintaining_balance}) for member #{@member.full_name}"
        }
      end

      #not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
