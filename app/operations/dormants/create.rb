module Dormants
  class Create
    def initialize(config:)
      @config = config
      @branch = @config[:branch]
      @as_of = @config[:as_of]
      @user = @config[:current_user]
      @transaction_date = Date.today
      @data_store_type = "DORMANT"
      @current_date = ::Utils::GetCurrentDate.new(config: { branch: @branch }).execute!
      @records = []
      @total_dormant_fee = 0.0
      @withdraw_data = []

      @data_store = DataStore.create(
        meta: {
          data_store_type: @data_store_type,
          branch_id: @branch.id,
          branch_name: @branch.name,
          as_of: @as_of,
          transaction_date: @current_date,
          date_approved: ""
          
        },
        data: {
          accounting_entry: {
            book: "JVB",
            reference_number: "",
            date_prepared: @transaction_date,
            company_name: Settings.company_name,
            branch_id: @branch.id,
            prepared_by: @user.to_s,
            particular: "To record fee for dormant accounts",
            debit_journal_entries: [],
            credit_journal_entries: [],
            journal_entries: [],
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
      total_balance = @records.sum { |record| record[:balance] }
      @total_dormant_fee = @records.sum { |record| record[:dormant_fee].to_f }


      @data_store.data['header'] << {
        name: "Withdraw Payment",
        account_type: "SAVINGS",
        account_subtype: "K-IMPOK",
        total_amount: total_balance.round(2),  
        total_payment: @total_dormant_fee.round(2)  
      }
    end

  
    def process_data_record!
      dormant_member_ids = []
      members = Member.where(branch_id: @branch).where.not(status: 'pending')
      two_years_ago = Date.today - 2.years

      members.each do |member|
        member_savings = MemberAccount.where(member_id: member.id, account_subtype: 'K-IMPOK').last
        member_savings_id = member_savings.id
        next unless member_savings

 
        balance = member_savings.balance
        next if balance == 0.0

        account_transaction = AccountTransaction.where(subsidiary_id: member_savings.id)
                                                .where.not("data ->> 'is_interest' = ?", 'true')
                                                .order(:transacted_at).last
        next unless account_transaction

        if account_transaction.transacted_at.to_date <= two_years_ago
          dormant_member_ids << member.id

          dormant_fee = balance >= 30 ? 30.0 : balance
          @total_dormant_fee += dormant_fee

          # withdraw_data = {
          #   "name" => "Withdraw Payment",
          #   "loan_id" => "",
          #   "loan_product_id" => nil,
          #   "savings_account_id" => member_savings_id,
          #   "enabled" => true,
          #   "amount" => dormant_fee.to_f, 
          #   "record_type" => "WP"
          # }

         
          @records << {
            id: member.id,
            full_name: "#{member.last_name}, #{member.first_name} #{member.middle_name}",
            subsidiary_id: member_savings_id,
            center_id: member_savings.center_id,
            center_name: Center.find(member_savings.center_id).name,
            member_status: member.status,
            balance: balance.to_f,  
            dormant_fee: dormant_fee.to_f,
            last_transaction: account_transaction.transacted_at,
            last_transaction_type: account_transaction.data['is_withdraw'] == true ? 'Withdraw' : 'Deposit'
            # withdraw_data: [withdraw_data]  
          }
        end
      end
    end

    def execute!
      process_data_record!
      process_data_header!

      @data_store.update!(
        data: {
          accounting_entry: @data_store.data['accounting_entry'], 
          header: @data_store.data['header'],                     
          record: @records,                                       
          total_payment: @total_dormant_fee.round(2)             
        }
      )
      
      @data_store.save!  
      @data_store        
    end
  end
end
