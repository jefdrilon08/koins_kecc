module TransferMemberRecords
    class ValidateApprove < AppValidator
      def initialize(config:)
        super()

        @config       = config
        @transfer_member_records   = config[:transfer_member_records]
        @user         = config[:user]
        @data_accounting_entry_to = @transfer_member_records.data.with_indifferent_access[:accounting_entry_to]
        @data_accounting_entry_from = @transfer_member_records.data.with_indifferent_access[:accounting_entry_from]
       
      end

      def execute!
        if @transfer_member_records.blank?
          @errors[:messages] << {
            key: "transfer_member_records",
            message: "record Not Found"
          }
        end

        if @user.blank?
           @errors[:messages] << {
            key: "user",
            message: "user not found"
          }
        end

        if @data_accounting_entry_from[:particular].blank?
          @errors[:messages] << {
            key: "particular_from",
            message: "no particular found in accounting entry from"
          }
        end

        if @data_accounting_entry_to[:particular].blank?
          @errors[:messages] << {
            key: "particular_from",
            message: "no particular found in accounting entry to"
          }
        end


        
        #not_yet_implemented!

        @errors[:messages].each do |o|
          @errors[:full_messages] << o[:message]
        end

        @errors
      end
   
  end
end
