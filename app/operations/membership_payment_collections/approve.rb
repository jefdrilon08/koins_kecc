module MembershipPaymentCollections
  class Approve
    def initialize(config:)
      @config   = config
      @membership_payment_collection  = @config[:membership_payment_collection]
      @user     = @config[:user]

      @data = @membership_payment_collection.try(:data).try(:with_indifferent_access)

      @data_id_payments         = @membership_payment_collection.id_payments
      @data_membership_payments = @membership_payment_collection.membership_payments
      @data_equities            = @membership_payment_collection.equities
      @data_accounting_entry    = @membership_payment_collection.accounting_entry

      @date_approved  = Date.today
    end

    def execute!
      post_accounting_entry!

      process_id_payments!
      process_membership_payments!
      process_equities!

      @data[:approved_by] = @user.full_name

      # Update accounting entry with reference number
      @data[:accounting_entry][:id]               = @accounting_entry.id
      @data[:accounting_entry][:reference_number] = @accounting_entry.reference_number
      @data[:accounting_entry][:status]           = @accounting_entry.status
      @data[:accounting_entry][:approved_by]      = @accounting_entry.approved_by

      @membership_payment_collection.update!(
        status: "approved",
        date_approved: @date_approved,
        data: @data
      )

      @membership_payment_collection
    end

    private

    # Nothing to do here
    def process_id_payments!
      @data_id_payments.each do |o|
        config  = {
          id_payment: o,
          date_paid: @date_approved,
          user: @user,
          particular: @data_accounting_entry[:particular]
        }
      end
    end

    def process_membership_payments!
      @data_membership_payments.each do |o|
        config  = {
          date_paid: @date_approved,
          membership_payment: o,
          member: Member.find(o[:member_id]),
          user: @user,
          particular: @data_accounting_entry[:particular]
        }

        ::MembershipPaymentCollections::ApproveMembershipPaymentHash.new(
          config: config
        ).execute!
      end
    end

    def process_equities!
      @data_equities.each do |o|
        config  = { 
          date_paid: @date_approved,
          equity_payment: o,
          user: @user,
          particular: @data_accounting_entry[:particular]
        }

        ::MembershipPaymentCollections::ApproveEquityPaymentHash.new(
          config: config
        ).execute!
      end
    end

    def post_accounting_entry!
      # Create new accounting entry
      config  = {
        accounting_entry_data: @data_accounting_entry.with_indifferent_access,
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
  end
end
