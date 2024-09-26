module BillingForWriteoffCollection
  class Create
    def initialize(config: )  
      @config           = config
      @branch           = @config[:branch]
      @center           = @config[:center]
      @transaction_date = Date.today
      @data_store_type  = "BILLING_FOR_WRITEOFF_COLLECTION"
      @current_date     = ::Utils::GetCurrentDate.new(
                            config: {
                              branch: @branch
                            }
                          ).execute!

      @data_store = DataStore.create(
        meta: {
          data_store_type: @data_store_type,
          branch_id: @branch.id,
          branch_name: @branch.name,
          center_id: @center.id,
          center_name: @center.name,
          transaction_date: @current_date,
          date_approved: ""
        },
        data: {
          accounting_entry: {
            book: "JVB",
            reference_number: "",
            date_prepared: @transaction_date,
            company_name: Settings.company_name,
            branch: @branch.to_s.upcase,
            prepared_by: @user.to_s,
            particular: "to record collection for the accounts that previously written off",
            debit_journal_entries: [],
            credit_journal_entries: [],
            journal_entries: [],
            branch_id: @branch.id,
            branch_name: @branch.name,
            status: "display",
            data: {
              or_number: "",
              ar_number: "",
              si_number:"",
              check_number: "",
              check_voucher_number: "",
              date_of_check: "",
              sub_reference_number: "",
              payee: ""
            }
          },
          header: [],
          record: [],
          total_cash_payment: 0.0,
          total_payment: 0.0
        },
        status: "pending"
      )
    end
   
    def process_data_header!
      @header = []
      @h_data = Loan.where(status: 'writeoff' , center_id: @center.id)
    
      @h_data.pluck(:loan_product_id).uniq.each do |hd|
        @header << LoanProduct.find(hd)
      end
     
      @header.uniq.each do |headers|
        @data_store.data['header'] << {
          name: headers.name,
          loan_id: headers.id,
          total_amount: 0.0,
          principal_amount: 0.0,
          interest_amount: 0.0
        }
      end
      @data_store.data['header'] << {
        name: "Withdraw Payment",
        total_amount: 0.0
      }
      # @data_store.data['header'] << {
      #   name: "CBU",
      #   total_amount: 0.0
      # }
      # @data_store.data['header'] << {
      #   name: "MBS",
      #   total_amount: 0.0
      # }
    end
   
    def process_data_record!
      @h_data.joins(:member).order(:last_name).pluck(:member_id).uniq.each do |records|
        total_per_member     = @h_data.where(member_id: records)
        total_balance_member = total_per_member.sum(:principal_balance).to_f + total_per_member.sum(:interest_balance).to_f
        @data_store.data['record'] << {
          member_id: records,
          name:      Member.find(records).full_name,
          enabled:   false,
          total_cash_payment: total_balance_member,
          total_payment: total_balance_member,
          loan_data: []
        }
      end

      @data_store.data['record'].each do |loan_data|
        @header.each do |hld|
          l = Loan.where("member_id = ? and loan_product_id = ? and status = 'writeoff'" , loan_data[:member_id] , hld.id).last       
          if l.present?
            loan_data[:loan_data] << {
              name: hld.name,
              loan_id: l.id,
              loan_product_id: l.loan_product_id,
              enabled: true,
              amount: l.total_balance.to_f,
              expected_amount: l.total_balance.to_f,
              principal_amount: 0.0,
              interest_amount: 0.0,
              record_type: "LOAN_PAYMENT",
              loan_amort: []
            }
          else
            loan_data[:loan_data] << {
              name: hld.name,
              loan_id: '',
              loan_product_id: nil,
              enabled: false,
              amount: 0.0,
              expected_amount: 0.0,
              principal_amount: 0.0,
              interest_amount: 0.0,
            }
          end 
        end
        mem_acc  = MemberAccount.where(member_id: loan_data[:member_id] , account_type: 'SAVINGS' , account_subtype: 'K-IMPOK').last.id
        loan_data[:loan_data] << {
          name: "Withdraw Payment",
          loan_id: '',
          loan_product_id: nil,
          savings_account_id: mem_acc,
          enabled: true,
          amount: 0.0,
          record_type: "WP"
        }
        #mem_acc = MemberAccount.where(member_id: loan_data[:member_id] , account_type: 'SAVINGS' , account_subtype: 'K-IMPOK').last.id

        # a = MemberAccount.where("member_id = ? and account_subtype IN ('K-IMPOK','CBU','Maintaining Balance Savings')", "#{loan_data[:member_id]}").ids
        # a.each do |mem_a|
         
        # member_acc = MemberAccount.find(mem_a)
        # if member_acc.account_subtype == 'K-IMPOK'
        #     loan_data[:loan_data] << {
        #     name: "Withdraw Payment",
        #     loan_id: '',
        #     loan_product_id: nil,
        #     savings_account_id: member_acc,
        #     enabled: true,
        #     amount: 0.0,
        #     record_type: "WP"
        #   }
        #   elsif member_acc.account_subtype == 'CBU'
        #   loan_data[:loan_data] << {
        #     name: "CBU",
        #     loan_id: '',
        #     loan_product_id: nil,
        #     savings_account_id: member_acc,
        #     enabled: true,
        #     amount: 0.0,
        #     record_type: "WP"
        #   }
        # elsif member_acc.account_subtype == 'Maintaining Balance Savings'
        #   loan_data[:loan_data] << {
        #     name: "Maintaining Balance",
        #     loan_id: '',
        #     loan_product_id: nil,
        #     savings_account_id: member_acc,
        #     enabled: true,
        #     amount: 0.0,
        #     record_type: "WP"
        #   }

        # end
        
        # end
        
      end
    end
   
    def execute!
      process_data_header!
      process_data_record!
      @data_store.save!
      @data_store
    end
      
  end
end
