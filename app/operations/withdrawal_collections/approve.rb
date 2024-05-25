module WithdrawalCollections
  class Approve
    def initialize(config:)
      @config                 = config
      @withdrawal_collection  = @config[:withdrawal_collection]
      @user                   = @config[:user]

      @data = @withdrawal_collection.try(:data).try(:with_indifferent_access)
      @data_withdrawals       = @withdrawal_collection.withdrawals
      @data_accounting_entry  = @withdrawal_collection.accounting_entry

      @branch = @withdrawal_collection.branch

      @date_approved  = ::Utils::GetCurrentDate.new(
                          config: {
                            branch: @branch
                          }
                        ).execute!
    end

    def execute!
      post_accounting_entry!
      process_withdrawals!
      process_sms!

      @data[:approved_by] = @user.full_name

      # Update accounting entry with reference number
      @data[:accounting_entry][:id]               = @accounting_entry.id
      @data[:accounting_entry][:reference_number] = @accounting_entry.reference_number
      @data[:accounting_entry][:status]           = @accounting_entry.status
      @data[:accounting_entry][:approved_by]      = @accounting_entry.approved_by

      @withdrawal_collection.update!(
        status: "approved",
        date_approved: @date_approved,
        data: @data
      )

      @withdrawal_collection
    end

    private

    def process_sms!
      @data[:records].each do |rec|
        @member = Member.find(rec["member"]["id"])
        #transactions
        @total_savings = 0.00
        @total_insurance_payment = 0.00
        @total_equity = 0.00

        rec[:records].each do |rl|

          if rl[:enabled] == true and rl[:record_type] == "SAVINGS"
            @total_savings += rl[:amount].to_f
          elsif rl[:enabled]== true and rl[:record_type] == "INSURANCE"
            @total_insurance_payment += rl[:amount].to_f
          elsif rl[:enabled]== true and rl[:record_type] == "EQUITY"
            @total_equity += rl[:amount].to_f
          end

        end
        @total_withdraw = @total_savings+@total_insurance_payment+@total_equity
        @formatted_total_payment = '%.2f' % @total_withdraw
        if @member.mobile_number.present?
          if @member.data["sms_record"].present?
            if @member.data["sms_record"]["loan_maturity"].to_date > Date.today && @total_withdraw > 0
              content="Hi! #{@member.first_name}! \nIkaw ay nag-withdraw sa K-COOP ng #{@formatted_total_payment} na may REF##{@accounting_entry[:reference_number]} \ndate: #{@accounting_entry[:date_posted].to_fs(:long)} \nMag-log in sa iyong My k-coins account para sa detalye."
              config = {
                mobile_number: @member.mobile_number,
                content: content
              }
              ::SmsBlast::Send.new(config: config).execute!
            end
          end
        end
      end
    end

    def process_withdrawals!
      @data_withdrawals.each do |o|
        config  = {
          date_paid: @date_approved,
          withdrawal: o,
          member: Member.find(o[:member_id]),
          user: @user,
          particular: @data_accounting_entry[:particular]
        }

        ::WithdrawalCollections::ApproveWithdrawalHash.new(
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
