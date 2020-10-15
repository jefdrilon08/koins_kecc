module SavingsInsuranceTransferCollections
  class ValidateApprove < AppValidator
    def initialize(config:)
      super()

      @config                                 = config
      @savings_insurance_transfer_collection  = @config[:savings_insurance_transfer_collection]
    end

    def execute!
      if @savings_insurance_transfer_collection.blank?
        @errors[:messages] << {
          key: "savings_insurance_transfer_collection",
          message: "record not found"
        }
      end

      if @savings_insurance_transfer_collection.present? and !@savings_insurance_transfer_collection.pending?
        @errors[:messsages] << {
          key: "savings_insurance_transfer_collection",
          message: "cannot approve non-pending record"
        }
      end

      if @savings_insurance_transfer_collection.present?
        data  = @savings_insurance_transfer_collection.data.with_indifferent_access

        # Get balances of members
        savings_account_ids = data[:records].map{ |o| o[:savings_account_id] }
        savings_accounts    = MemberAccount.where(id: savings_account_ids)

        savings_accounts.each do |a|
          r = data[:records].select{ |o| o[:savings_account_id] == a.id }.first

        end

        if data[:records].size == 0
          @errors[:messages] << {
            key: "records",
            message: "no records found"
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
