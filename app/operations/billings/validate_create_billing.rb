module Billings
  class ValidateCreateBilling < AppValidator
    def initialize(config:)
      super()
      @config           = config
      @collection_date  = @config[:collection_date]
      @branch           = Branch.where(id: @config[:branch_id]).first
      @center           = Center.where(id: @config[:center_id]).first
      @user             = @config[:user]
    end

    def execute!
      if @user.blank?
        @errors[:messages] << {
          key: "user",
          message: "user not found"
        }
      end

      if @branch.blank?
        @errors[:messages] << {
          key: "branch",
          message: "branch not found"
        }
      end

      if @center.blank?
        @errors[:messages] << {
          key: "center",
          message: "center not found"
        }
      end

      if @branch.present? and @center.present? and Billing.where(branch_id: @branch.id, center_id: @center.id, status: "pending").count > 0
        @errors[:messages] << {
          key: "billing",
          message: "Please resolve pending billings for #{@center.to_s} / #{@branch.to_s} before creating a new billing."
        }
      end

      if @branch.present? and @center.present? and Billing.where(branch_id: @branch.id, center_id: @center.id, status: "save").count > 0
        @errors[:messages] << {
          key: "billing",
          message: "Please resolve save billings for #{@center.to_s} / #{@branch.to_s} before creating a new billing."
        }
      end

      if @branch.present? and @center.present? and Billing.where(branch_id: @branch.id, center_id: @center.id, status: "checked").count > 0
        @errors[:messages] << {
          key: "billing",
          message: "Please resolve checked billings for #{@center.to_s} / #{@branch.to_s} before creating a new billing."
        }
      end

      if @collection_date.blank?
        @errors[:messages] << {
          key: "collection_date",
          message: "collection date required"
        }
#      elsif @collection_date.to_date > Date.today
#        @errors[:messages] << {
#          key: "collection_date",
#          message: "collection date should be less than #{Date.today.strftime("%b %d, %Y")}"
#        }
      end

      if @branch and @center and @collection_date
        if Billing.where(branch_id: @branch.id, center_id: @center.id, collection_date: @collection_date, status: "pending").count > 0
          @errors[:messages] << {
            key: "system",
            message: "billing already present for collection date #{@collection_date.to_s}"
          }
        end
      end

      #not_yet_implemented!

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors
    end
  end
end
