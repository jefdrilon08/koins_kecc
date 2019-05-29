module Adjustments
  module SubsidiaryAdjustments
    class AddMember
      def initialize(config:)
        @config = config

        @adjustment_record  = @config[:adjustment_record]
        @member             = @config[:member]
        @account_subtype    = @config[:account_subtype]
        @adjustment         = @config[:adjustment]
        @member_account     = @config[:member_account]
        @amount             = @config[:amount].to_f.round(2)

        @data = @adjustment_record.data.with_indifferent_access
      end

      def execute!
        record  = {
          member: {
            id: @member.id,
            first_name: @member.first_name,
            last_name: @member.last_name,
            middle_name: @member.middle_name
          },
          center: {
            id: @member.center.id,
            name: @member.center.name
          },
          member_account: {
            id: @member_account.id,
            account_type: @member_account.account_type,
            account_subtype: @member_account.account_subtype
          },
          amount: @amount,
          adjustment: @adjustment
        }

        @data[:records] << record

        @adjustment_record.data = @data

        @adjustment_record.save!
      end
    end
  end
end
