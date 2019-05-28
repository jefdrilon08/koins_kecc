module Billings
  class ValidateZeroOut < AppValidator
    def initialize(config:)
      super()

      @config   = config
      @billing  = @config[:billing]
      @user     = @config[:user]

      @current_date = @config[:current_date] || Date.today

      @data = @billing.try(:data).try(:with_indifferent_access)
    end

    def execute!
      if !@billing.pending?
        @errors[:messages] << {
          key: "billing",
          message: "billing not pending"
        }
      end

      if @billing.blank?
        @errors[:messages] << {
          key: "billing",
          message: "billing not found"
        }
      end

      #not_yet_implemented!

      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }

      @errors
    end
  end
end
