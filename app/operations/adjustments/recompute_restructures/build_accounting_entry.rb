module Adjustments
  module RecomputeRestructures
    class BuildAccountingEntry
      def initialize(config:)
        @config = config
        @recompute_restructure = @config[:recompute_restructure]
        @book = "JVB"
        @loan = Loan.find(@config[:recompute_restructure].loan)
        @particular   = default_particular
        @branch =  @loan.branch
        @prepared_by = @config[:user]
        @current_date = ::Utils::GetCurrentDate.new(
                        config: {
                          branch: @branch
                        }
                      ).execute!
        @accounting_entry_data  = {
          book: @book,
          date_prepared: @current_date.strftime("%B %d, %Y"),
          company_name: Settings.company_name,
          company_address: Settings.company_address,
          branch: @branch.name.to_s.upcase,
          prepared_by: @prepared_by.full_name,
          particular: @particular,
          debit_journal_entries: [],
          credit_journal_entries: [],
          journal_entries: [],
          branch_id: @branch.id,
          branch_name: @branch.name,
          status: "display",
          data: {
            or_number: "",
            ar_number: "",
            check_number: "",
            check_voucher_number: "",
            date_of_check: "",
            sub_reference_number: "",
            payee: ""
          }
        }

        
      end
      def execute!
        #raise @recompute_restructure.data["loans"].last["total_loanable_amount"].inspect
        @accounting_entry_data[:credit_journal_entries] = build_credit_journal_entries!
        @accounting_entry_data[:debit_journal_entries]  = build_debit_journal_entries!

        @accounting_entry_data[:credit_journal_entries].each do |j|
          @accounting_entry_data[:journal_entries] << {
            id: "",
            post_type: "CR",
            accounting_code_id: j[:accounting_code_id],
            accounting_code_name: "#{j[:code]} - #{j[:name]}",
            amount: j[:amount]
          }
        end

        @accounting_entry_data[:debit_journal_entries].each do |j|
          @accounting_entry_data[:journal_entries] << {
            id: "",
            post_type: "DR",
            accounting_code_id: j[:accounting_code_id],
            accounting_code_name: "#{j[:code]} - #{j[:name]}",
            amount: j[:amount]
          }
        end

        @accounting_entry_data
        
        
      end
      
      private

      def build_debit_journal_entries!
        journal_entries = []
        
        # debit loan recievable
          @loan.data["accounting_entry"]["debit_journal_entries"].each do |l|
            total_diff = l["amount"].to_f - @recompute_restructure.data["loans"].last["total_loanable_amount"].to_f
            account_trans = AccountingCode.find("731adf24-dc8a-41a4-a804-292562b390fa")
            if total_diff > 0
              if l["accounting_code_id"] == "a6913ac9-1a85-495a-8f80-d394549dc52e"
                journal_entries << {
                  accounting_code_id: account_trans.id,
                  code: account_trans.code,
                  name: account_trans.name,
                  amount: total_diff.abs
                }
              else
                journal_entries << {
                  accounting_code_id: l["accounting_code_id"],
                  code: l["code"],
                  name: l["name"],
                  amount: total_diff.abs
                }
              end
            end
          end #end of loan loop

          @recompute_restructure.data["loans"].each do |rd|

            rd["loan_details"].each do |ld| #loan details
              account_code = AccountingCode.find(ld["loan_product"]["receivable_accounting_code_id"])
              total_diff = ld["loan_product"]["old_receivable_amount"].to_f - ld["principal_balance"].to_f
              if total_diff < 0
                journal_entries << {
                  accounting_code_id: account_code.id,
                  code: account_code.code,
                  name: account_code.name,
                  amount: total_diff.abs
                }
              end #end of total_diff < 0
            
            end #end of rd["loan_details"]


            rd["insurance_details"].each do |idetails|
              account_code = AccountingCode.find(idetails["accounting_entry"])
              total_diff = (idetails["old_value"].to_f - idetails["value"].to_f).round(2)
              if total_diff < 0
                journal_entries << {
                  accounting_code_id: account_code.id,
                  code: account_code.code,
                  name: account_code.name,
                  amount: total_diff.abs
                }
              end #end of total_diff < 0
            end #end of rd["insurance_details"].each

          end #end of @recompute_restructure.data["loans"]
          account_code = AccountingCode.find("9f4b1331-cd5a-4edb-9920-a5029759885d")
          total_diff = (@recompute_restructure.data["loans"].last["total_old_service_fee"].to_f - @recompute_restructure.data["loans"].last["total_service_fee"].to_f).round(2)
          if total_diff < 0
            journal_entries << {
              accounting_code_id: account_code.id,
              code: account_code.code,
              name: account_code.name,
              amount: total_diff.abs
            }
          end

        
        journal_entries
        

      end

      def build_credit_journal_entries!
        journal_entries = []
        
        # credit loan recievable
          @loan.data["accounting_entry"]["debit_journal_entries"].each do |l|
            total_diff = l["amount"].to_f - @recompute_restructure.data["loans"].last["total_loanable_amount"].to_f
            if total_diff < 0 
              journal_entries << {
                accounting_code_id: l["accounting_code_id"],
                code: l["code"],
                name: l["name"],
                amount: total_diff.abs
              }
            end
          end #end of loan loop

          @recompute_restructure.data["loans"].each do |rd|

            rd["loan_details"].each do |ld| #loan details
              account_code = AccountingCode.find(ld["loan_product"]["receivable_accounting_code_id"])
              account_code_interest = AccountingCode.find(ld["loan_product"]["interest_receivable_accounting_code_id"])

              total_diff = ld["loan_product"]["old_receivable_amount"].to_f - ld["principal_balance"].to_f
              total_diff_interest = ld["loan_product"]["old_interest_receivable_amount"].to_f - ld["k_sagip_interest_balance"].to_f
              if total_diff > 0
                journal_entries << {
                  accounting_code_id: account_code.id,
                  code: account_code.code,
                  name: account_code.name,
                  amount: total_diff.abs
                }

              end #end of total_diff < 0
            
              journal_entries << {
                  accounting_code_id: account_code_interest.id,
                  code: account_code_interest.code,
                  name: account_code_interest.name,
                  amount: total_diff_interest.abs
              }
            end #end of rd["loan_details"]


            rd["insurance_details"].each do |idetails|
              account_code = AccountingCode.find(idetails["accounting_entry"])
              total_diff = (idetails["old_value"].to_f - idetails["value"].to_f).round(2)
              if total_diff > 0
                journal_entries << {
                  accounting_code_id: account_code.id,
                  code: account_code.code,
                  name: account_code.name,
                  amount: total_diff.abs
                }
              end #end of total_diff < 0
            end #end of rd["insurance_details"].each

          end #end of @recompute_restructure.data["loans"]
          account_code = AccountingCode.find("9f4b1331-cd5a-4edb-9920-a5029759885d")
          total_diff = (@recompute_restructure.data["loans"].last["total_old_service_fee"].to_f - @recompute_restructure.data["loans"].last["total_service_fee"].to_f).round(2)
          if total_diff > 0
            journal_entries << {
              accounting_code_id: account_code.id,
              code: account_code.code,
              name: account_code.name,
              amount: total_diff.abs
            }
          end

        
        journal_entries
        

      end

      def default_particular
        
        "To adjust in recording K-SAGIP loan due to enhancement of policy - #{@loan.member.full_name}"
      end


    end
  end
end
