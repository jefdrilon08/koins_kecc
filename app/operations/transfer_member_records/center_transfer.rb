module TransferMemberRecords
  class CenterTransfer
      def initialize(config:)
       @config = config
       @from_center = Center.find(@config[:from_center])
       @to_center   = Center.find(@config[:to_center])
       @transfer_member_records = TransferMemberRecord.find(@config[:transfer_member_record])
       @data = @transfer_member_records.data.with_indifferent_access
       @accounting_entry_from = @data[:accounting_entry_from]
       @accounting_entry_to = @data[:accounting_entry_to]
       @members_from_center = Member.where(center_id: @from_center)


      end

      def execute!
        record = []

        @data[:records] = @members_from_center.map{ |mem|
          member_account = MemberAccount.where(member_id: mem.id)
          active_loans = Loan.where(member_id: mem.id, status: "active")
          
          temp = {
              member: [],
              transfer_to_center: [],
              transfer_from_center: [],
              member_accounts: [],
              loan_records:[]}

              temp[:member] = {
                id: mem.id,
                center_id: mem.center_id,
                branch_id: mem.branch_id,
                first_name: mem.first_name,
                middle_name: mem.middle_name,
                last_name: mem.last_name,
                identification_number: mem.identification_number
              }

              temp[:transfer_to_center] = {
                id: @to_center.id,
                name: @to_center.name,
                so_id: @to_center.user_id
              }

              temp[:transfer_from_center]=  {
                id: @from_center.id,
                name: @from_center.name,
                so_id: @from_center.user_id
              }
            
              member_account.each do |mem_a|
                mem = {
                  id: mem_a[:id],
                  member_id: mem_a[:member_id],
                  account_type: mem_a[:account_type],
                  account_subtype: mem_a[:account_subtype],
                  balance: mem_a[:balance].to_f
                }
                temp[:member_accounts] << mem
              end

              active_loans.each do |ac|
                ac = {
                  loan_id: ac.id,
                  loan_product_id: ac.loan_product_id,
                  member_id: ac.member_id,
                  branch_id: ac.branch_id,
                  center_id: ac.center_id,
                  date_approved: ac.date_approved,
                  date_released: ac.date_released,
                  principal: ac.principal.to_f,
                  interest: ac.interest.to_f,
                  principal_paid: ac.principal_paid.to_f,
                  interest_paid: ac.interest_paid.to_f,
                  principal_balance: ac.principal_balance.to_f,
                  interest_balance: ac.interest_balance.to_f,
                  pn_number: ac.pn_number,
                  term: ac.term,
                  num_installments: ac.num_installments
                }
                temp[:loan_records] << ac 
              end
              temp
           
        }

        @data[:records]
        @transfer_member_records.data = @data
        @data[:accounting_entry_from]= ::TransferMemberRecords::BuildAccountingEntryFrom.new(config:{
                                          accounting_entry_from: @accounting_entry_from, 
                                          record: @data[:records],
                                          transfer_member_records: @transfer_member_records,
                                          accounting_entry_to: @accounting_entry_to
                                          }).execute!

        @data[:accounting_entry_to]= ::TransferMemberRecords::BuildAccountingEntryTo.new(config:{
                                          accounting_entry_from: @accounting_entry_from, 
                                          record: @data[:records],
                                          transfer_member_records: @transfer_member_records,
                                          accounting_entry_to: @accounting_entry_to
                                          }).execute!


        @transfer_member_records.save!
      end
  end
end
