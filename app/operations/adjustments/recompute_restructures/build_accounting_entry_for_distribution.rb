module Adjustments
  module RecomputeRestructures
    class BuildAccountingEntryForDistribution
      def initialize(config:)
        @config = config
        @for_savings_distribution = @config[:for_savings_distribution]
        
        @user = @config[:user]
        @account_transaction_details = @config[:account_transaction_details]
        @account_transaction = @config[:account_transaction]
        #raise  @account_transaction[:amount].to_f.inspect
        @book = "JVB"
        @loan =  Loan.find(@account_transaction_details.loan) 
        @branch =  @loan.branch
        @particular   = default_particular
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
          prepared_by: @user.full_name,
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
        @accounting_entry_data[:debit_journal_entries]  = build_debit_journal_entries!
        @accounting_entry_data[:credit_journal_entries] = build_credit_journal_entries!

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
        account_code = AccountingCode.find("731adf24-dc8a-41a4-a804-292562b390fa")
        if @for_savings_distribution  == nil
          total_amount = @account_transaction[:amount].to_f
        else
          total_amount = @for_savings_distribution
          
        end
    
        journal_entries << {
                  accounting_code_id: account_code.id,
                  code: account_code.code,
                  name: account_code.name,
                  amount: total_amount
              }
        journal_entries
      end

      def build_credit_journal_entries!
        journal_entries = []
        account_transaction_data = @account_transaction
        
        if @loan.status == "active"
        
          if @for_savings_distribution == nil
            
            total_amount_principal = account_transaction_data.data.with_indifferent_access[:total_principal_paid].to_f.abs
          
            total_amount_interest = account_transaction_data.data.with_indifferent_access[:total_interest_paid].to_f.abs
            account_code_principal = AccountingCode.find("a6913ac9-1a85-495a-8f80-d394549dc52e")
            account_code_interest = AccountingCode.find("a09f6aea-9ab9-4e55-a994-ca8c4dd5de33")
            journal_entries << {
                  accounting_code_id: account_code_principal.id,
                  code: account_code_principal.code,
                  name: account_code_principal.name,
                  amount: total_amount_principal
                }
            journal_entries << {
                  accounting_code_id: account_code_interest.id,
                  code: account_code_interest.code,
                  name: account_code_interest.name,
                  amount: total_amount_interest
                }
            else
              
              account_code_regular = AccountingCode.find("b7c23e58-e44e-46ae-a3ec-b5081d6eed32")
              account_code_gk = AccountingCode.find("f719c253-a9ba-4d81-ae52-dc8d8d0848f2")
              total_amount = @for_savings_distribution 
              if @loan.member.member_type == "GK"
                journal_entries << {
                  accounting_code_id: account_code_gk.id,
                  code: account_code_gk.code,
                  name: account_code_gk.name,
                  amount: total_amount
                }
              else
                journal_entries << {
                  accounting_code_id: account_code_regular.id,
                  code: account_code_regular.code,
                  name: account_code_regular.name,
                  amount: total_amount
                }
              end


            end
          
        

        else
          account_code_regular = AccountingCode.find("b7c23e58-e44e-46ae-a3ec-b5081d6eed32")
          account_code_gk = AccountingCode.find("f719c253-a9ba-4d81-ae52-dc8d8d0848f2")
          total_amount = account_transaction_data.amount.abs
          if @loan.member.member_type == "GK"
            journal_entries << {
                  accounting_code_id: account_code_gk.id,
                  code: account_code_gk.code,
                  name: account_code_gk.name,
                  amount: total_amount
                }
          else
            journal_entries << {
                  accounting_code_id: account_code_regular.id,
                  code: account_code_regular.code,
                  name: account_code_regular.name,
                  amount: total_amount
                }
          end
          
        end
        journal_entries
      end


      def default_particular
        "To record rebates of #{ @loan.member.full_name } for k-sagip availment on old policy.  "
      end
    end
  end
end
