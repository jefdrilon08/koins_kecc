module TransferSavings
  class Generate

    def initialize(config:)
      @config = config
      @transfer_savings_records = TransferSavingsRecord.find(@config[:transfer_savings])
      @user = User.find(@config[:user])
      @account_subtype_psa = "Personal Savings Account"
      @account_subtype_mbs = "Maintaining Balance Savings"
      @accounting_code_mbs = AccountingCode.find("cb330c40-a450-4e86-94f9-4c850e4a1d92")
      @accounting_code_psa = AccountingCode.find("ba2c06dc-749a-4ca3-b09c-950669385126")
      @members = Member.where("branch_id = ? ","#{@transfer_savings_records.branch_id}")

      

    end

    def execute!
      build_data!
      build_accounting_entry!
      @transfer_savings_records
    end

    
    def build_data!

      @data = @transfer_savings_records.data.with_indifferent_access
      @members.each do |mm|
        psa_account = MemberAccount.where("member_id=? and account_subtype =?", "#{mm.id}", "#{@account_subtype_psa}")
        psa_account.each do |psa|
          @psa_id = psa[:id]
          @psa_balance = psa[:balance].to_f
        end
        
        mbs_account = MemberAccount.where(member_id: mm.id, account_subtype: @account_subtype_mbs)
        mbs_account.each do |mbs|
          @mbs_id = mbs[:id]
          @mbs_balance = mbs[:balance].to_f
        end
        

          if @psa_balance != 0.0
            @data[:member_records] << {
              member_id:    mm[:id],
              member_name:  mm.full_name,
              member_status: mm.status,
              center: {
                center_id:  mm[:center_id],
                center_name: Center.find(mm[:center_id]).name
              },
              psa_account_id: @psa_id,
              psa_balance:    @psa_balance,
              mbs_account_id: @mbs_id,
              mbs_balance:    @mbs_balance
            }
          end
    
      end
      @data[:total_psa] = @data[:member_records].inject(0){ |sum, hash| sum + hash[:psa_balance] }.round(2).to_f
      @transfer_savings_records.data = @data
    end 
    def build_accounting_entry!
      @accounting_entry = @data[:accounting_entry]
      @accounting_entry[:debit_journal_entries] = []
      @accounting_entry[:credit_journal_entries] = []
      @accounting_entry[:journal_entries] = []
      @accounting_entry[:particular] = default_particular!
      @accounting_entry[:debit_journal_entries] = build_debit_journal_entries!
      @accounting_entry[:credit_journal_entries]= build_credit_journal_entries!
      
      @accounting_entry[:debit_journal_entries].each do |adbj|
        @accounting_entry[:journal_entries] << {
          id: "",
          post_type: "DR",
          accounting_code_id: adbj[:accounting_code_id],
          accounting_code_name: adbj[:name],
          amount: adbj[:amount].to_f.round(2)
        }
      end

      @accounting_entry[:credit_journal_entries].each do |adbj|
        @accounting_entry[:journal_entries] << {
          id: "",
          post_type: "CR",
          accounting_code_id: adbj[:accounting_code_id],
          accounting_code_name: adbj[:name],
          amount: adbj[:amount].to_f.round(2)
        }
      end

      @accounting_entry
    end

    def build_debit_journal_entries!
      journal_entries = []
      journal_entries << {
        accounting_code_id: @accounting_code_psa.id,
        code: @accounting_code_psa.code,
        name: @accounting_code_psa.name,
        amount: @data[:total_psa].to_f.round(2)
      }
    end

    def build_credit_journal_entries!
      journal_entries = []
      journal_entries << {
        accounting_code_id: @accounting_code_mbs.id,
        code: @accounting_code_mbs.code,
        name: @accounting_code_mbs.name,
        amount: @data[:total_psa].to_f.round(2)
      }
    end

    def default_particular!
      "To Transfer Personal Savings Account to Maintaining Balance Savings Amounting to - #{@data[:total_psa]} - #{@accounting_entry[:branch].upcase}."
    end

  end
end
