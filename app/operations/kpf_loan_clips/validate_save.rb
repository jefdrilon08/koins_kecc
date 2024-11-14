module KpfLoanClips
  class ValidateSave < AppValidator
    def initialize(config:)
      super()

      @config             = config
      @branch             = @config[:branch]
      @center             = @config[:center]
      @collection_date    = @config[:collection_date]
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

      if @center.present? and Member.active.where(center_id: @center.id).count == 0
        @errors[:messages] << {
          key: "center",
          message: "No active members found for center #{@center.name}"
        }
      end

      #not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end