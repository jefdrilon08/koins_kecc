module TransferMemberRecords
  class AddMember
      def initialize(config:)
        @config = config
        @member = @config[:member]
        @center = @config[:center]
        @member_accounts= @config[:member_accounts]
        @transfer_member_records= @config[:transfer_member_records]
        @data = @transfer_member_records.data.with_indifferent_access
        @accounting_entry_to = @data[:accounting_entry_to]
        @accounting_entry_from = @data[:accounting_entry_from]


      end

      def execute!
       
        record = {
          member: [],
          transfer_to_center: [],
          member_accounts: []
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
