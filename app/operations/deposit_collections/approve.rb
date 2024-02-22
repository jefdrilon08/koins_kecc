module DepositCollections
  class Approve
    def initialize(config:)
      @config                 = config
      @deposit_collection     = @config[:deposit_collection]
      @user                   = @config[:user]

      @data                   = @deposit_collection.try(:data).try(:with_indifferent_access)
      @data_deposits          = @deposit_collection.deposits
      @data_accounting_entry  = @deposit_collection.accounting_entry

      @branch                 = @deposit_collection.branch

      if Settings.activate_microinsurance
        @date_approved        = @deposit_collection.collection_date
      else
        @date_approved        = ::Utils::GetCurrentDate.new(
                                  config: {
                                    branch: @branch
                                  }
                                ).execute!
      end
    end

    def execute!
      post_accounting_entry!
      process_deposits!
      process_sms!

      @data[:approved_by] = @user.full_name

      # Update accounting entry with reference number
      @data[:accounting_entry][:id]                         = @accounting_entry.id
      @data[:accounting_entry][:reference_number]           = @accounting_entry.reference_number
      @data[:accounting_entry][:status]                     = @accounting_entry.status
      @data[:accounting_entry][:approved_by]                = @accounting_entry.approved_by
      @data[:accounting_entry][:sub_reference_number]       = @accounting_entry.sub_reference_number

      @deposit_collection.update!(
        status: "approved",
        date_approved: @date_approved,
        data: @data
      )

      @deposit_collection
    end

    private
    def process_sms!
      @data[:records].each do |rec|
        @member = Member.find(rec["member"]["id"])

        @total_savings = 0.00
        @total_insurance_payment = 0.00
        @total_equity = 0.00

        rec[:records].each do |rl|

          if rl[:enabled] == true and rl[:record_type] == "SAVINGS"
            @total_savings += rl[:amount].to_f
          elsif rl[:enabled]== true and rl[:record_type] == "INSURANCE"
            @total_insurance_payment += rl[:amount].to_f
          end
        end

        content= "Good Day! #{@member.full_name} your payment has been posted to our system with reference number #{@accounting_entry[:reference_number]}. transaction date: #{@accounting_entry[:date_posted].to_fs(:long)} \nSavings Payment: #{@total_savings} \nInsurance Payment: #{@total_insurance_payment}"
        config = {
          mobile_number: @member.mobile_number,
          content: content
        }

        #::SmsBlast::Send.new(config: config).execute!
        puts config.inspect
      end
    end

    def process_deposits!
      @data_deposits.each do |o|
        config  = {
          date_paid: @date_approved,
          deposit: o,
          member: Member.find(o[:member_id]),
          user: @user,
          particular: @data_accounting_entry[:particular]
        }

        ::DepositCollections::ApproveDepositHash.new(
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
