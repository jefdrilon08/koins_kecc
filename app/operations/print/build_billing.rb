module Print
  class BuildBilling
    include ActionView::Helpers::NumberHelper

    def initialize(config:)
      @config   = config
      @billing  = config[:billing]
      @user     = config[:user]

      @data = {}
    end

    def execute!
      @data[:id]  = @billing.id

      @data
    end
  end
end
