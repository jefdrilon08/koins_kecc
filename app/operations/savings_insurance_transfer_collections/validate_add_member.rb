module SavingsInsuranceTransferCollections
  class ValidateAddMember < AppValidator
    def initialize(config:)
      super()

      @config                                 = config
      @savings_insurance_transfer_collection  = @config[:savings_insurance_transfer_collection]
      @member                                 = @config[:member]
      @amount                                 = @config[:amount]

      if @savings_insurance_transfer_collection.clip
        @loan_product_id                        = @config[:loan_product_id]
        @principal                              = @config[:principal]
        @term                                   = @config[:term]
        @num_installments                       = @config[:num_installments]
        @maturity_date                          = @config[:maturity_date]
        @effective_date                          = @config[:effective_date]
      end

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

      if !@savings_insurance_transfer_collection.clip
        if @member.present? and @savings_insurance_transfer_collection.member_ids.include?(@member.id)
          @errors[:messages] << {
            key: "message",
            message: "Member already included"
          }
        end
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

      if @savings_account.present? and @savings_account.maintaining_balance > (@savings_account.balance - @amount)
        @errors[:messages] << {
          key: "savings_account",
          message: "Not enough balance for savings #{@savings_subtype} (Maintaining balance: #{@savings_account.maintaining_balance}) for member #{@member.full_name}"
        }
      end

      if @savings_insurance_transfer_collection.clip
        if !@loan_product_id.present?
          @errors[:messages] << {
            key: "loan_product",
            message: "Loan Product is required"
          }
        end

        if !@principal.present?
          @errors[:messages] << {
            key: "principal",
            message: "Principal is required"
          }
        end

        if !@term.present?
          @errors[:messages] << {
            key: "term",
            message: "Term is required"
          }
        end

        if !@num_installments.present?
          @errors[:messages] << {
            key: "num_installments",
            message: "Num Installments is required"
          }
        end

        if !@maturity_date.present?
          @errors[:messages] << {
            key: "maturity_date",
            message: "Maturity Date is required"
          }
        end

        if !@effective_date.present?
          @errors[:messages] << {
            key: "effective_date",
            message: "Effectivity Date is required"
          }
        end
      end

      #not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
