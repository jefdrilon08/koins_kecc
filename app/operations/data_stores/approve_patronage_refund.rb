module DataStores
  class ApprovePatronageRefund
    def initialize(config:)
      @config = config
    
      @patronage_refund = @config[:patronage_refund]
      #@closing_date               = @monthly_closing_collection.closing_date
      @data                       = @patronage_refund.data.with_indifferent_access
      #raise @data.inspect
      
      @user                       = @config[:user]
      @current_date               = Date.today

      @data_accounting_entry  = @data[:accounting_entry]

      # Change this
      @particular = "To record declaration of Patronage Refund 2018"

    
    end

    def execute!
      #post_accounting_entry!
      perform_deposits!

      @data[:approved_by] = @user.full_name

      # Update accounting entry with reference number
      #@data[:accounting_entry][:id]               = @accounting_entry.id
      #@data[:accounting_entry][:reference_number] = @accounting_entry.reference_number
      #@data[:accounting_entry][:status]           = @accounting_entry.status
      #@data[:accounting_entry][:approved_by]      = @accounting_entry.approved_by

      @patronage_refund.update!(
        status: "approved",
        #closed_at: @current_date,
        data: @data
      )

      @icpr
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
                            configA config
                          ).execute!

      @accounting_entry
    end

    def perform_deposits!
      @data[:details].each do |r|
        
        r[:final_count].each do |fc|
          
          if fc[:total_member_interest]
        
            account_subtype = ["K-IMPOK", "CBU"]
          
            member_account  = MemberAccount.where("member_id = ? and account_subtype IN (?)", fc[:member_id], account_subtype )
        
          member_account.each do |ma|
          
            if ma.account_subtype == "K-IMPOK"
              
              deposit_amount = fc[:member_savings_total].to_f
            else
              deposit_amount = fc[:member_cbu_total].to_f
            end
              

            config  = {
              date_paid: @current_date,
              deposit: deposit_amount,
              member: ma,
              user: @user,
              particular: @particular
            }

            ::DataStores::ApprovePatronageRefundHash.new(
              config: config
            ).execute!
          end
          #raise "jef".inspect
        end
        end

      end
    end
  end
end
