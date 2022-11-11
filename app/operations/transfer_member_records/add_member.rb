module TransferMemberRecords
  class AddMember
      def initialize(config:)
        @config = config
        @member = @config[:member]
        @center = @config[:center]  
        @member_accounts= @config[:member_accounts]
        @active_loans= @config[:active_loans]
        @transfer_member_records= @config[:transfer_member_records]
        @data = @transfer_member_records.data.with_indifferent_access
        @accounting_entry_to = @data[:accounting_entry_to]
        @accounting_entry_from = @data[:accounting_entry_from]


      end

      def execute!
       
        record = {
          member: [],
          transfer_to_center: [],
          member_accounts: [],
          loan_records:[]
        }
        record[:member] = {
          id: @member.id,
          center_id: @member.center_id,
          branch_id: @member.branch_id,
          first_name: @member.first_name,
          middle_name: @member.middle_name,
          last_name: @member.last_name,
          identification_number: @member.identification_number
        }
        record[:transfer_to_center] = {
          id: @center.id,
          name: @center.name,

        }
        record[:member_accounts] = @member_accounts
       
        if @active_loans.present?
          @active_loans.each do |ac|

           record[:loan_records] << {
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
          end
        end

        @data[:records] << record
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
