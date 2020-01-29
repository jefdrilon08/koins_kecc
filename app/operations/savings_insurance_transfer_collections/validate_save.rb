module SavingsInsuranceTransferCollections
  class ValidateSave < AppValidator
    def initialize(config:)
      super()

      @config             = config
      @branch             = @config[:branch]
      @center             = @config[:center]
      @collection_date    = @config[:collection_date]
      @savings_subtype    = @config[:savings_subtype]
      @insurance_subtype  = @config[:insurance_subtype]
    end

    def execute!
      if @branch.blank?
        @errors[:messages] << {
          key: "branch",
          message: "Branch required"
        }
      end

      if @center.blank?
        @errors[:messages] << {
          key: "center",
          message: "Center required"
        }
      end

      if @branch.present? and @center.present? and @branch.id != @center.branch_id
        @errors[:messages] << {
          key: "center",
          message: "Invalid center"
        }
      end

      if @collection_date.blank?
        @errors[:messages] << {
          key: "collection_date",
          message: "Collection date required"
        }
      end

      if @savings_subtype.blank?
        @errors[:messages] << {
          key: "savings_subtype",
          message: "Savings subtype required"
        }
      end

      if @insurance_subtype.blank?
        @errors[:messages] << {
          key: "insurance subtype",
          message: "Insurance subtype required"
        }
      end

      if @branch.present? and @center.present? and SavingsInsuranceTransferCollection.pending.where(branch_id: @branch.id, center_id: @center.id).count > 0
        @errors[:messages] << {
          key: "savings_insurance_transfer_collection",
          message: "Please approve current pending transaction"
        }
      end

      not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
