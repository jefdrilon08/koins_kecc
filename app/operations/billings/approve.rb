module Billings
  class Approve
    include ActionView::Helpers::NumberHelper
    def initialize(config:)
      @config   = config
      @billing  = @config[:billing]
      @user     = @config[:user]

      @branch = @billing.branch

      @date_approved  = ::Utils::GetCurrentDate.new(
                          config: {
                            branch: @branch
                          }
                        ).execute!

      @data = @billing.try(:data).try(:with_indifferent_access)

      @data_loan_payments     = @billing.loan_payments
      @data_deposits          = @billing.deposits
      @data_insurance         = @billing.insurance
      @data_equity         = @billing.equity



      @data_withdraw_payments = @billing.withdraw_payments
      @data_accounting_entry  = @billing.accounting_entry

      @collection_date  = @billing.collection_date
    end

    def execute!
      # issue_or_number!
      # issue_ar_number!

      post_accounting_entry!
      process_loan_payments!
      process_savings!
      process_insurance!
      process_withdraw_payments!
      process_equity!


      process_send_sms!

      @data[:approved_by] = @user.full_name

      # Update accounting entry with reference number

      @data[:accounting_entry][:id]               = @accounting_entry.id
      @data[:accounting_entry][:reference_number] = @accounting_entry.reference_number
      @data[:accounting_entry][:status]           = @accounting_entry.status
      @data[:accounting_entry][:approved_by]      = @accounting_entry.approved_by

      # Update OR and AR Number for billing (with accounting entry)
      # @data[:or_number]                           = @or_number
      # @data[:ar_number]                           = @ar_number
      # @data[:accounting_entry][:data][:or_number] = @or_number
      # @data[:accounting_entry][:data][:ar_number] = @ar_number

      # # Update OR and AR Number for member records
      # @data[:records].each do |record|
      #   record[:member][:or_number] = @or_number
      #   record[:member][:ar_number] = @ar_number
      # end

      @billing.update!(
        status: "approved",
        date_approved: @date_approved,
        data: @data
      )

      @billing
    end

    private

    # def issue_or_number!
    #   cmd = ::Branches::IssueOrNumber.new(
    #     branch: @branch
    #   )

    #   @or_number = cmd.execute!
    # end

    # def issue_ar_number!
    #   cmd = ::Branches::IssueArNumber.new(
    #     branch: @branch
    #   )

    #   @ar_number = cmd.execute!
    # end

    def process_loan_payments!
      @data_loan_payments.each do |o|
        loan  = Loan.find(o[:loan_id])

        config  = {
          loan_payment: o,
          date_paid: @date_approved,
          user: @user,
          particular: @data_accounting_entry[:particular],
          loan: loan
        }

        ::Billings::ApproveLoanPaymentHash.new(
          config: config
        ).execute!
      end
    end

    def process_savings!
      @data_deposits.each do |o|
        config  = {
          date_paid: @date_approved,
          deposit: o,
          user: @user,
          particular: @data_accounting_entry[:particular]
        }

        ::Billings::ApproveSavingsDepositHash.new(
          config: config
        ).execute!
      end
    end

    def process_equity!
      @data_equity.each do |o|
        config  = {
          date_paid: @date_approved,
          deposit: o,
          user: @user,
          particular: @data_accounting_entry[:particular]
        }


        ::Billings::ApproveEquityDepositHash.new(
          config: config
        ).execute!
      end
    end

    def process_withdraw_payments!
      @data_withdraw_payments.each do |o|
        config  = {
          date_paid: @date_approved,
          withdraw_payment: o,
          user: @user,
          particular: @data_accounting_entry[:particular]
        }

        ::Billings::ApproveWithdrawPaymentHash.new(
          config: config
        ).execute!
      end
    end

    def process_insurance!
      @data_insurance.each do |o|
        config  = {
          date_paid: @date_approved,
          insurance_deposit: o,
          user: @user,
          particular: @data_accounting_entry[:particular]
        }

        ::Billings::ApproveInsuranceDepositHash.new(
          config: config
        ).execute!
      end
    end

    def post_accounting_entry!
      # Setup OR and AR Number
      # @data_accounting_entry[:data][:or_number] = @or_number
      # @data_accounting_entry[:data][:ar_number] = @ar_number

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

    def process_send_sms!
      @data[:records].each do |rec|
        @member = Member.find(rec["member"]["id"])
        #transactions
        @total_loan_payment = 0.00
        @total_cash_payment = 0.00
        @total_withdraw_payment = 0.00
        @total_payment = 0.00
        rec[:records].each do |rl|
          if rl[:enabled] == true and rl[:record_type] == "LOAN_PAYMENT"
            @total_loan_payment += rl[:amount].to_f
          elsif rl[:enabled] == true and rl[:record_type] == "SAVINGS"
            @total_cash_payment += rl[:amount].to_f
          elsif rl[:enabled]== true and rl[:record_type] == "INSURANCE"
            @total_cash_payment += rl[:amount].to_f
          elsif rl[:enabled] == true and rl[:record_type] == "WP"
            @total_withdraw_payment += rl[:amount].to_f
          end

        end
        @total_payment = @total_cash_payment+@total_loan_payment

        #if @member.data.key?("sms_record") code para kahit wala pang sms record hindi mag error.
        if @member.data.key?("sms_record")
         if @member.data["sms_record"]["loan_maturity"].to_date > Date.today && @total_payment > 0
          content= "Hi #{@member.first_name}! \nAng iyong hulog #{@total_payment} ay natanggap na ng K-COOP RE##{@accounting_entry[:reference_number]} \ndate: #{@accounting_entry[:date_posted].to_fs(:long)} \nMag-log in sa iyong My k-coins account para sa detalye."
          config = {
              mobile_number: @member.mobile_number,
              content: content
            }
            #::SmsBlast::Send.new(config: config).execute!
            puts config.inspect

            #may payment ng sms pero walang payment sa billing
            elsif @total_payment == 0.0 
              content= "Hi #{@member.first_name}! \n"
              config = {
                mobile_number: @member.mobile_number,
              content: content
            }
            #::SmsBlast::Send.new(config: config).execute!
            puts config.inspect
         end

         #withdrawal sms
         if @total_withdraw_payment > 0
          content= "Hi #{@member.first_name}! \nIkaw ay nag-withdraw sa K-COOP ng #{@total_withdraw_payment} na may REF##{@accounting_entry[:reference_number]} \nMag-log in saiyong My k-coins account para sa detalye."
          config = {
            mobile_number: @member.mobile_number,
            content: content
          }
          #::SmsBlast::Send.new(config: config).execute!
          puts config.inspect
         end
        end
      end
    end
  end
end
