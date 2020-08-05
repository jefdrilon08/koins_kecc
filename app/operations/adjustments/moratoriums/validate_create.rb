module Adjustments
  module Moratoriums
    class ValidateCreate < AppValidator
      attr_accessor :errors

      def initialize(config:)
        super()
        @config = config

        @branch           = @config[:branch]
        @center           = @config[:center]
        @member           = @config[:member]
        @loans            = @config[:loans]
        @date_initialized = @config[:date_initialized]
        @number_of_days   = @config[:number_of_days].try(:to_i)
        @user             = @config[:user]
      end

      def execute!

        if @branch.blank?
          @errors[:messages] << {
            key: "branch",
            message: "Branch required"
          }
        end

        if @center.blank?
          @errors[:messages] << {
            key: "center",
            message: "Center required"
          }
        end

        if @member.blank?
          @errors[:messages] << {
            key: "member",
            message: "Member required"
          }
        end

        if @member.present? and Loan.active.where(member_id: @member.id).count == 0
          @errors[:messages] << {
            key: "member",
            message: "Member has no active loans"
          }
        end

        if !@loans.any?
          @errors[:messages] << {
            key: "loans",
            message: "No loans provided"
          }
        end

        if @member.present? and MemberMoratorium.pending.where(member_id: @member.id).count > 0
          @errors[:messages] << {
            key: "member",
            message: "Member still has pending moratorium"
          }
        end

        if @date_initialized.blank?
          @errors[:messages] << {
            key: "date_initialized",
            message: "Date initialized required"
          }
        end

        if @number_of_days.blank?
          @errors[:messages] << {
            key: "number_of_days",
            message: "Number of days required"
          }
        elsif @number_of_days == 0
          @errors[:messages] << {
            key: "number_of_days",
            message: "Invalid number of days"
          }
        end

        if @user.blank?
          @errors[:messages] << {
            key: "user",
            message: "User required"
          }
        end

        #not_yet_implemented!
      
        @errors[:messages].each do |m|
          @errors[:full_messages] << m[:message]
        end

        @errors
      end
    end
  end
end
