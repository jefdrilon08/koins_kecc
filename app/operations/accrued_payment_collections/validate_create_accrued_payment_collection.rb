module AccruedPaymentCollections
  class ValidateCreateAccruedPaymentCollection < AppValidator
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

      if AccruedBilling.where("status = 'pending' and branch_id = ? and center_id = ? " , @branch.id , @center.id).count > 0
        @errors[:messages] << {
          key: "billing",      
          message: "Please resolve pending accrued billing for #{@center.to_s} / #{@branch.to_s} before creating a new one."
        }
      end
      
      if Loan.where("center_id = ? and loans.data ->> 'accrued_interest' IS NOT NULL" , @center).count == 0
        @errors[:messages] << {
          key: "billing",      
          message: "There's no Accrued Balance for #{@center.to_s} / #{@branch.to_s} ."
        }
      end
      

#      if @branch and @center and @collection_date
#        if MembershipPaymentCollection.where(branch_id: @branch.id, center_id: @center.id, collection_date: @collection_date).count > 0
#          @errors[:messages] << {
#            key: "system",
#            message: "membership_payment_collection already present for collection date #{@collection_date.to_s}"
#          }
#        end
#      end

      #not_yet_implemented!

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors
    end
  end
end
