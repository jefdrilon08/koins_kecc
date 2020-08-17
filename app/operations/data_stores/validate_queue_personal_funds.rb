module DataStores
  class ValidateQueuePersonalFunds < AppValidator
    def initialize(config:)
      super()

      @config = config

      @branch = @config[:branch]
      @as_of  = @config[:as_of].try(:to_date)
    end

    def execute!
      if @branch.blank?
        @errors[:messages] << {
          key: "branch",
          message: "Branch not found"
        }
      elsif @branch.present?
        is_cutoff = ::Utils::IsCutoff.new(branch: @branch).execute!

        if !is_cutoff
          @errors[:messages] << {
            key: "cut_off",
            message: "Not yet cutoff period"
          }
        end
      end

      if @as_of.blank?
        @errors[:messages] << {
          key: "as_of",
          message: "as_of required"
        }
      end

      if @branch.present? and @as_of.present? and DataStore.personal_funds.where("meta->>'branch_id' = ? AND DATE(meta->>'as_of') = ?", @branch.id, @as_of).count > 0
        @errors[:messages] << {
          key: "data_store",
          message: "personal funds record present for #{@as_of} and #{@branch.name}"
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
