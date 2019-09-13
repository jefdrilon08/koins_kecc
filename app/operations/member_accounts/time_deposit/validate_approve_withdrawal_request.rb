module MemberAccounts
  module TimeDeposit
    class ValidateApproveWithdrawalRequest < AppValidator
      def initialize(config:)
        super()

        @config         = config
        @data_store     = @config[:data_store]
        @user           = @config[:user]

        @data = @data_store.data.with_indifferent_access
      end

      def execute!
        if @data_store.blank?
          @errors[:messages] << {
            key: "data_store",
            message: "Data store not found"
          }
        else
          if !@data_store.pending?
            @errors[:messages] << {
              key: "data_store",
              message: "Data store is not pending"
            }
          end
        end

        if @user.blank?
          @errors[:messages] << {
            key: "user",
            message: "user not found"
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
end
