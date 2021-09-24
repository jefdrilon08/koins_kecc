module InsuranceMonthlyClosingCollections
  class Approve
    def initialize(config:)
      @config = config

      @insurance_monthly_closing_collection = @config[:insurance_monthly_closing_collection]
      @closing_date                         = @insurance_monthly_closing_collection.closing_date
      @data                                 = @insurance_monthly_closing_collection.data.with_indifferent_access
      @user                                 = @config[:user]
      @current_date                         = ::Utils::GetCurrentDate.new(
                                                config: {
                                                  branch: @branch
                                                }
                                              ).execute!


      # Change this
      @particular = "Interest deposit"
    end

    def execute!
      perform_deposits!

      @data[:approved_by] = @user.full_name

      @insurance_monthly_closing_collection.update!(
        status: "approved",
        closed_at: @current_date,
        data: @data
      )

      @insurance_monthly_closing_collection
    end

    private

    def perform_deposits!
      @data[:records].each do |r|
        member_account  = MemberAccount.find(r[:member_account][:id])
        member          = member_account.member

        config  = {
          date_paid: @closing_date,
          deposit: r,
          member: member,
          user: @user,
          particular: @particular
        }

        ::InsuranceMonthlyClosingCollections::ApproveDepositHash.new(
          config: config
        ).execute!
      end
    end
  end
end
