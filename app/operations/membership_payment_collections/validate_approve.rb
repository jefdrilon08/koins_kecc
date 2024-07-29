module MembershipPaymentCollections
  class ValidateApprove < AppValidator
    def initialize(config:)
      super()

      @config                         = config
      @membership_payment_collection  = @config[:membership_payment_collection]
      @user                           = @config[:user]

      @data = @membership_payment_collection.try(:data).try(:with_indifferent_access)
    end

    def execute!
      if @membership_payment_collection.blank?
        @errors[:messages] << {
          key: "membership_payment_collection",
          message: "membership_payment_collection not found"
        }
      end

      if @data.present? && @data[:or_number].blank? && @data[:si_number].blank?
        @errors[:messages] << {
          key: "or_number",
          message: "no OR/SI number"
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
