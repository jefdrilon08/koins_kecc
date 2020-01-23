module InsuranceFundTransferCollections
  class ValidateApprove < AppValidator
    def initialize(config:)
      super()

      @config                              = config
      @insurance_fund_transfer_collection  = @config[:insurance_fund_transfer_collection]
      @user                                = @config[:user]

      @data                                = @insurance_fund_transfer_collection.try(:data).try(:with_indifferent_access)
    end

    def execute!
      if @insurance_fund_transfer_collection.blank?
        @errors[:messages] << {
          key: "insurance_fund_transfer_collection",
          message: "insurance_fund_transfer_collection not found"
        }
      end

      if @data.present? and @data[:records].size == 0
        @errors[:messages] << {
          key: "records",
          message: "no records found"
        }
      end

      if Settings.activate_microinsurance
        if @insurance_fund_transfer_collection.is_remote_deposit?
          if @data.present? and @data[:or_number].blank?
            @errors[:messages] << {
              key: "or_number",
              message: "no or number found"
           }
          end
        end
      end

      #not_yet_implemented!

      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }

      @errors
    end
  end
end
