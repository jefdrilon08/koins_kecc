module TransferMemberRecords
  class SaveParticular

    def initialize(config:)
      @config = config

      @transfer_member_record = TransferMemberRecord.find(@config[:transfer_member_record][:id])
      @particular_to = @config[:particular_to]
      @particular_from = @config[:particular_from]
      @transfer_member_record_data = @transfer_member_record.data.with_indifferent_access
    
    end
    def execute!
    @transfer_member_record_data[:accounting_entry_to][:particular] = @particular_to
    @transfer_member_record_data[:accounting_entry_from][:particular] = @particular_from
    @transfer_member_record.update!(data: @transfer_member_record_data)
    @transfer_member_record
    end     
  end
end
