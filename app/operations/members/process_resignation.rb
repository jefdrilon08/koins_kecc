module Members
  class ProcessResignation
    def initialize(config:)
      @config = config

      @data = @config[:data]
      @user = @config[:user]

      puts @data

      @member = Member.find(@data[:member][:id])

      @member_data  = @member.data.with_indifferent_access
    end

    def execute!
      accounting_entry  = post_accounting_entry!

      process_withdrawals!(accounting_entry.reference_number)

      resignation_data  = {
        type: @data[:member_resignation_type][:name],
        code: @data[:member_resignation_type][:particular][:code],
        reason: @data[:member_resignation_type][:particular][:name],
        accounting_reference_number: accounting_entry.reference_number
      }

      resignation_records = @member_data[:resignation_records]

      if resignation_records.blank?
        resignation_records = []
      end

      resignation_records << {
        branch: @data[:branch],
        center: @data[:center],
        date_resigned: @data[:date_resigned],
        member_resignation_type: @data[:member_resignation_type]
      }

      @member_data[:resignation]          = resignation_data
      @member_data[:resignation_records]  = resignation_records

      @member.update!(
        status: "resigned",
        date_resigned: @data[:date_resigned],
        data: @member_data
      )

    end

    private

    def process_withdrawals!(accounting_entry_reference_number)
      @data[:equity_accounts].each do |o|
        config  = {
          date_paid: @data[:date_resigned],
          withdrawal: {
            amount: o[:balance],
            member_account_id: o[:id]
          },
          member: @member,
          user: @user,
          particular: @data[:accounting_entry][:particular],
          accounting_entry_reference_number: accounting_entry_reference_number
        }

        ::WithdrawalCollections::ApproveWithdrawalHash.new(
          config: config
        ).execute!
      end
    end

    def post_accounting_entry!
      accounting_entry_data = @data[:accounting_entry]

      accounting_entry  = ::Accounting::AccountingEntries::Save.new(
                            config: {
                              id: nil,
                              accounting_entry_data: accounting_entry_data,
                              user: @user
                            }
                          ).execute!

      accounting_entry  = ::Accounting::AccountingEntries::Approve.new(
                            config: {
                              accounting_entry: accounting_entry,
                              user: @user
                            }
                          ).execute!

      accounting_entry
    end
  end
end
