module Members
  class ValidateFetchResignationDetails < AppValidator
    def initialize(config:)
      super()

      @config = config

      @member = @config[:member]
      @user   = @config[:user]
    end

    def execute!
      if @member.blank?
        @errors[:messages] << {
          key: "member",
          message: "Member not found."
        }
      elsif !@member.active?
        @errors[:messages] << {
          key: "member",
          message: "Member is not active."
        }
      else
        active_loans  = Loan.active.where(member_id: @member.id)

        if active_loans.any?
          active_loans.each do |o|
            @errors[:messages] << {
              key: "loan_#{o.id}",
              message: "Active loan balance for #{o.loan_product.to_s}: #{o.total_balance}"
            }
          end
        end
      end

      if @user.blank?
        @errors[:messages] << {
          key: "user",
          message: "User not foud"
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
