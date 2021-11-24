module InsuranceMonthlyClosingCollections
  class Approve
    def initialize(config:)
      @config = config

      @insurance_monthly_closing_collection = @config[:insurance_monthly_closing_collection]
      @closing_date                         = @insurance_monthly_closing_collection.closing_date
      @data                                 = @insurance_monthly_closing_collection.data.with_indifferent_access
      @user                                 = @config[:user]

      @data_accounting_entry                = @data[:accounting_entry]
      
      if Settings.activate_microinsurance
        @current_date = ::Utils::GetCurrentDate.new(
                          config: {
                            branch: @branch
                          }
                        ).execute!
      else
        @current_date = @closing_date
      end


      # Change this
      @particular = "Interest deposit"
    end

    def execute!
      perform_deposits!

      if Settings.activate_microinsurance 
        if @data_accounting_entry.present?
          post_accounting_entry!
        end
      end

      @data[:approved_by] = @user.full_name

      @insurance_monthly_closing_collection.update!(
        status: "approved",
        closed_at: @current_date,
        data: @data
      )

      @insurance_monthly_closing_collection
    end

    private

    def post_accounting_entry!
      # Create new accounting entry
      config  = {
        accounting_entry_data: @data_accounting_entry,
        user: @user
      }

      accounting_entry  = ::Accounting::AccountingEntries::Save.new(
                            config: config
                          ).execute!

      # Post to books
      config  = {
        accounting_entry: accounting_entry,
        user: @user
      }

      @accounting_entry = ::Accounting::AccountingEntries::Approve.new(
                            config: config
                          ).execute!

      @accounting_entry
    end

    def perform_deposits!
      @data[:records].each do |r|
        member_account  = MemberAccount.find(r[:member_account][:id])
        member          = member_account.member

        config  = {
          date_paid: @current_date,
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
