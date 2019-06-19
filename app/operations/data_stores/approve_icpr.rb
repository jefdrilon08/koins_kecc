module DataStores
  class ApproveIcpr
    def initialize(config:)
      @config = config
    
      @icpr = @config[:icpr]
      #@closing_date               = @monthly_closing_collection.closing_date
      @data                       = @icpr.data.with_indifferent_access
      
      @meta = @icpr.meta.with_indifferent_access
      @branch = Branch.find(@meta[:branch_id])

     # raise @data[:details].inspect
      
      @user                       = @config[:user]
      @current_date               = ::Utils::GetCurrentDate.new(
                                        config: {
                                          branch: @branch
                                        }
                                      ).execute!

      @data_accounting_entry  = @data[:accounting_entry]

      # Change this
      @particular = "To record declaration of Interest for Share Capital #{@current_date.year}"

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

      @icpr.update!(
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
        #raise r[:member_name].inspect
        if r[:member_total_equity] 
        
          #  raise r[:member_id].inspect
          #end
          account_subtype = ["K-IMPOK", "CBU"]
          member_account  = MemberAccount.where("member_id = ? and account_subtype IN (?)", r[:member_id], account_subtype )
        
          member_account.each do |ma|

            if ma.account_subtype == "K-IMPOK"
              deposit_amount = r[:total_savings_distribute]
            else
              deposit_amount = r[:total_cbu_distribute]
            end

            config  = {
              date_paid: @current_date,
              deposit: deposit_amount,
              member: ma,
              user: @user,
              particular: @particular
            }

            ::DataStores::ApproveIcprHash.new(
              config: config
            ).execute!
          end

        end

      end
    end
  end
end
