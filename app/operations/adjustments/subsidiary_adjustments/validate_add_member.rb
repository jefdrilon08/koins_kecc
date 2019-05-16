module Adjustments
  module SubsidiaryAdjustments
    class ValidateAddMember < AppValidator
      def initialize(config:)
        super()

        @config = config

        @adjustment_record  = @config[:adjustment_record]
        @member             = @config[:member]
        @account_subtype    = @config[:account_subtype]
        @adjustment         = @config[:adjustment]
        @member_account     = @config[:member_account]
        @amount             = @config[:amount].to_f.round(2)
      end

      def execute!
        if @adjustment_record.blank?
          @errors[:messages] << {
            key: "adjustment_record",
            message: "Adjustment record not found"
          }
        elsif !@adjustment_record.pending?
          @errors[:messages] << {
            key: "adjustment_record",
            message: "Adjustment record not pending"
          }
        end

        if @member.blank?
          @errors[:messages] << {
            key: "member",
            message: "Member not found"
          }
        end

        if @member_account.blank?
          @errors[:messages] << {
            key: "member_account",
            message: "Member account not found"
          }
        end

        if @adjustment.blank?
          @errors[:messages] << {
            key: "adjustment",
            message: "Adjustment not found"
          }
        elsif !["ADD", "DEDUCT"].include?(@adjustment)
          @errors[:messages] << {
            key: "adjustment",
            message: "Invalid adjustment #{@adjustment}"
          }
        elsif @adjustment == "DEDUCT" and @member_account.present? and @amount.present?
          if (@member_account.balance - @amount) < @member_account.maintaining_balance
            @errors[:messages] << {
              key: "amount",
              message: "Insufficient funds to withdraw #{@amount}. Maintaining balance: #{@member_account.maintaining_balance}"
            }
          end
        end

        if @amount.blank?
          @errors[:messages] << {
            key: "amount",
            message: "Amount not found"
          }
        elsif @amount <= 0.00
          @errors[:messages] << {
            key: "amount",
            message: "Invalid amount #{@amount}"
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
