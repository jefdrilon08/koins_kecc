module CommissionCollections
  class ValidateCreate < AppValidator
    def initialize(config:)
      super()
      @config = config

      @start_date = @config[:start_date]
      @end_date   = @config[:end_date]
      @category   = @config[:category]
      @user       = @config[:user]
    end

    def execute!
      #not_yet_implemented!

      if @start_date.blank?
        @errors[:messages] << {
          key: "start_date",
          message: "Start date required"
        }
      end

      if @end_date.blank?
        @errors[:messages] << {
          key: "end_date",
          message: "End date required"
        }
      end

      if @end_date.present? and @start_date.present? and @category.present?
        if CommissionCollection.where(
            "start_date = ? AND end_date = ? AND category = ?",
            @start_date, 
            @end_date,
            @category
          ).any?

          @errors[:messages] << {
            key: "commission_collection",
            message: "Already created commission."
          }
        end
      end

      if @start_date.present? and @category.present?
        last_commission_collection = CommissionCollection.where(category: @category).order("date_prepared ASC").last

        if last_commission_collection.present?
          if @start_date <= last_commission_collection.end_date
            @errors[:messages] << {
              key: "commission_collection",
              message: "Start date must be advance in last generated commission."
            }
          end
        end
      end

      if @category.blank?
        @errors[:messages] << {
          key: "category",
          message: "Category required"
        }
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
