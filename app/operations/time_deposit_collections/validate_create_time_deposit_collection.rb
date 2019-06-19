module TimeDepositCollections
  class ValidateCreateTimeDepositCollection < AppValidator
    def initialize(config:)
      super()
      @config           = config
      @collection_date  = @config[:collection_date]
      @branch           = Branch.where(id: @config[:branch_id]).first
      @user             = @config[:user]
    end

    def execute!
      if @user.blank?
        @errors[:messages] << {
          key: "user",
          message: "user not found"
        }
      end

      if @branch.blank?
        @errors[:messages] << {
          key: "branch",
          message: "branch not found"
        }
      end

      if @collection_date.blank?
        @errors[:messages] << {
          key: "collection_date",
          message: "collection date required"
        }
      end

      if @branch.present? and TimeDepositCollection.pending.where(branch_id: @branch.id).count > 0
        @errors[:messages] << {
          key: "branch",
          message: "Branch #{@branch.to_s} still has pending transactions for time deposit"
        }
      end

      #not_yet_implemented!

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors
    end
  end
end
