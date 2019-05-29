module Adjustments
  module SubsidiaryAdjustments
    class DeleteMember
      def initialize(config:)
        @config             = config
        @adjustment_record  = @config[:adjustment_record]
        @member_account     = @config[:member_account]
        @user               = @config[:user]
        
        @data = @adjustment_record.data.with_indifferent_access
      end

      def execute!
        @data[:records] = @data[:records].select{ |o|
                            o[:member_account][:id] != @member_account.id
                          }

        @adjustment_record.data = @data

        @adjustment_record.save!
      end
    end
  end
end
