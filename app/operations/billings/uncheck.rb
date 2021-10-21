module Billings
  class Uncheck
    def initialize(config:)
      @config   = config
      @billing  = @config[:billing]
      @user     = @config[:user]

      @data = @billing.try(:data).try(:with_indifferent_access)

      
    end

    def execute!
      @data[:is_checked]  = false

      @data[:unchecker] = {
        id: @user.id,
        first_name: @user.first_name,
        last_name: @user.last_name,
        timestamp: Time.now
      }

      @billing.update!(
        data: @data
      )

      @billing
    end
  end
end
