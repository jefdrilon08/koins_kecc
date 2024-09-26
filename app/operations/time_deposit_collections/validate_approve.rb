module TimeDepositCollections
  class ValidateApprove < AppValidator
    def initialize(config:)
      super()
      @config                   = config
      @time_deposit_collection  = @config[:time_deposit_collection]
      @user                     = @config[:user]

      @data             = @time_deposit_collection.try(:data).try(:with_indifferent_access)
      @accounting_entry = @data[:accounting_entry]
    end

    def execute!
      if @time_deposit_collection.blank?
        @errors[:messages] << {
          key: "time_deposit_collection",
          message: "time_deposit_collection not found"
        }
      end

      if @data.present? and @data[:or_number].blank? and @accounting_entry[:book] == "CRB" and @data[:si_number].blank?
        @errors[:messages] << {
          key: "or_number",
          message: "no or/si number found"
        }
      end

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
