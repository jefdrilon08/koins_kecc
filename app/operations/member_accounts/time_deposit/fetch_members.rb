module MemberAccounts
  module TimeDeposit
    class FetchMembers
      def initialize(config:)
        @config           = config
        @settings         = Settings.time_deposit
        @account_subtype  = @settings.try(:account_subtype)

        if @settings.blank?
          raise "Settings for time_deposit not found"
        end

        if @account_subtype.blank?
          raise "Account subtype for time deposit not found"
        end

        @branch = @config[:branch]
        @center = @config[:center]
      end

      def execute!
        accounts  = MemberAccount.where(
                      account_type: "SAVINGS",
                      account_subtype: @account_subtype
                    )

        if @branch.present?
          accounts  = accounts.where(branch_id: @branch.id)
        end

        if @center.present?
          accounts  = accounts.where(center_id: @center.id)
        end

        members = Member.where(
                    id: accounts.pluck(:member_id).uniq
                  ).order("last_name ASC")
      end
    end
  end
end
