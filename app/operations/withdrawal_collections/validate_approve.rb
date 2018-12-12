module WithdrawalCollections
  class ValidateApprove < AppValidator
    def initialize(config:)
      super()

      @config                 = config
      @withdrawal_collection  = @config[:withdrawal_collection]
      @user                   = @config[:user]

      @data = @withdrawal_collection.try(:data).try(:with_indifferent_access)
    end

    def execute!
      if @withdrawal_collection.blank?
        @errors[:messages] << {
          key: "withdrawal_collection",
          message: "withdrawal_collection not found"
        }
      end

#      if @data.present? and @data[:or_number].blank?
#        @errors[:messages] << {
#          key: "or_number",
#          message: "no or number found"
#        }
#      end

      if @data.present? and @data[:accounting_entry][:particular].blank?
        @errors[:messages] << {
          key: "particular",
          message: "no particular found"
        }
      end

      if @data.present? and @data[:records].size == 0
        @errors[:messages] << {
          key: "records",
          message: "no records found"
        }
      end

      #not_yet_implemented!

      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }

      @errors
    end
  end
end
