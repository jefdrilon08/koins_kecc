module Adjustments
  module SubsidiaryAdjustments
    class Approve
      def initialize(config:)
        @config             = config
        @adjustment_record  = @config[:adjustment_record]
        @user               = @config[:user]

        @data = @adjustment_record.data.with_indifferent_access
        @meta = @adjustment_record.meta.with_indifferent_access

        @branch = Branch.find(@meta[:branch][:id])

        @date_approved  = ::Utils::GetCurrentDate.new(
                            config: {
                              branch: @branch
                            }
                          ).execute!

        @accounting_entry = @data[:accounting_entry]
        @records          = @data[:records]
      end

      def execute!
        # Process adjustment records
        @records.each do |o|
          c = {
            date_paid: @date_approved,
            amount: o[:amount].to_f.round(2),
            particular: @accounting_entry[:particular],
            member_account: MemberAccount.find(o[:member_account][:id]),
            user: @user
          }

          if o[:adjustment] == "ADD"
            ::Adjustments::SubsidiaryAdjustments::ApproveDepositHash.new(
              config: c
            ).execute!
          elsif o[:adjustment] == "DEDUCT"
            ::Adjustments::SubsidiaryAdjustments::ApproveWithdrawalHash.new(
              config: c
            ).execute!
          else
            raise "Invalid adjustment #{o[:adjustment]}"
          end
        end

        # Approve accounting entry
        approved_entry  = post_accounting_entry!

        @accounting_entry[:status]            = "approved"
        @accounting_entry[:date_posted]       = approved_entry.date_posted
        @accounting_entry[:approved_by]       = approved_entry.approved_by
        @accounting_entry[:reference_number]  = approved_entry.reference_number

        @data[:accounting_entry]  = @accounting_entry

        @adjustment_record.data = @data

        @adjustment_record.update!(
          status: "approved",
          approved_by: @user.to_s,
          date_approved: @date_approved
        )
      end

      def post_accounting_entry!
        # Create new accounting entry
        config  = {
          accounting_entry_data: @accounting_entry,
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

        accounting_entry  = ::Accounting::AccountingEntries::Approve.new(
                              config: config
                            ).execute!

        accounting_entry
      end
    end
  end
end
