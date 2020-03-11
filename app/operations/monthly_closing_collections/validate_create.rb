module MonthlyClosingCollections
  class ValidateCreate < AppValidator
    def initialize(config:)
      super()
      @config = config

      @closing_date     = @config[:closing_date]
      @branch           = @config[:branch]
      @user             = @config[:user]
      @account_subtype  = @config[:account_subtype]
    end

    def execute!
      #not_yet_implemented!

      if @closing_date.blank?
        @errors[:messages] << {
          key: "closing_date",
          message: "Closing date required"
        }
      end

      if @branch.blank?
        @errors[:messages] << {
          key: "branch",
          message: "Branch required"
        }
      end

      if @closing_date.present? and @branch.present?
        if MonthlyClosingCollection.where(
            "extract(month from closing_date) = ? AND extract(year from closing_date) = ? AND branch_id = ? AND account_subtype = ?",
            @closing_date.month, 
            @closing_date.year,
            @branch.id,
            @account_subtype
          ).any?

          @errors[:messages] << {
            key: "monthly_closing_collection",
            message: "Already closed"
          }
        end
      end

      if @user.blank?
        @errors[:messages] << {
          key: "user",
          message: "User required"
        }
      end
      
      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
