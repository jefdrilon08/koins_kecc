module InvoluntaryPayment
  class Create
    def initialize(config:)
      @config           = config
      @branch           = @config[:branch]
      @center           = @config[:center]
      @transaction_date = Date.today
      @data_store_type  = "INVOLUNTARY_PAYMENT"
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
            particular: "to record collection for the accounts that previously involuntary tagged",
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
    
      resigned_members = Member.where(status: 'resigned').pluck(:id)
      active_loans = Loan.where(member_id: resigned_members, status: 'active', center_id: @center.id)
      loan_product_ids = active_loans.pluck(:loan_product_id).uniq
      @header = LoanProduct.where(id: loan_product_ids)
    
      @header.uniq.each do |headers|
        @data_store.data['header'] << {
          name: headers.name,
          loan_id: headers.id,
          total_amount: 0.0,
          principal_amount: 0.0,
          interest_amount: 0.0
        }
      end
    
      # Do not add an unnecessary empty header entry
      # @data_store.data['header'] << { total_amount: 0.0 }
    end
    

    def process_data_record!
      resigned_members = Member.where(status: 'resigned').pluck(:id)
      active_loans = Loan.where(member_id: resigned_members, status: 'active', center_id: @center.id)

      active_loans.joins(:member).order('members.last_name').pluck(:member_id).uniq.each do |member_id|
        total_per_member     = active_loans.where(member_id: member_id)
        total_balance_member = total_per_member.sum(:principal_balance).to_f + total_per_member.sum(:interest_balance).to_f

        @data_store.data['record'] << {
          member_id: member_id,
          name:      Member.find(member_id).full_name,
          enabled:   false,
          total_cash_payment: total_balance_member,
          total_payment: total_balance_member,
          loan_data: []
        }
      end

      @data_store.data['record'].each do |loan_data|
        @header.each do |hld|
          l = Loan.where(member_id: loan_data[:member_id], loan_product_id: hld.id, status: 'active').last
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
              interest_amount: 0.0
            }
          end
        end
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