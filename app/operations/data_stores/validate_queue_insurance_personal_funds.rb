module DataStores
  class ValidateQueueInsurancePersonalFunds < AppValidator
    def initialize(config:)
      super()

      @config = config

      @branch = @config[:branch]
      @as_of  = @config[:as_of].try(:to_date)
      @member_status = @config[:member_status]
    end

    def execute!
      if @branch.blank?
        @errors[:messages] << {
          key: "branch",
          message: "Branch not found"
        }
      end

      if @as_of.blank?
        @errors[:messages] << {
          key: "as_of",
          message: "as_of required"
        }
      end

      if @member_status.blank?
        @errors[:messages] << {
          key: "member_status",
          message: "member status required"
        }
      end

      if @branch.present? and @as_of.present? and @member_status.present? and DataStore.insurance_personal_funds.where("meta->>'branch_id' = ? AND DATE(meta->>'as_of') = ? AND meta->>'member_status' = ?", @branch.id, @as_of, @member_status).count > 0
        @errors[:messages] << {
          key: "data_store",
          message: "Insurance personal funds record present for #{@as_of} and #{@branch.name}"
        }
      end

      #not_yet_implemented!

      @errors[:messages].each do |e|
        @errors[:full_messages] << e[:message]
      end

      @errors
    end
  end
end
