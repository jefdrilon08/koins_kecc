module Billings
  class Save
    def initialize(config:)
      @config   = config
      @billing  = @config[:billing]
      @user     = @config[:user]

      @data = @billing.try(:data).try(:with_indifferent_access)
    end

    def execute!
      @data[:save] = {
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
