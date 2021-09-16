module AccruedPaymentCollections
  class ProcessZero
    def initialize(config:)
      @config             = config
      @data_store_id      = @config[:data_store_id]
      @date_approved      = ::Utils::GetCurrentDate.new(
                            config: {
                              branch: @branch }).execute!
      @billing            = AccruedBilling.find(@data_store_id)
      @data               = @billing.try(:data).try(:with_indifferent_access)
      @member_data        = @data[:member_data]
    end

    def execute!
      @member_data.each_with_index do |r, i|
        r[:loan_data].each_with_index do |o, ii|
          if o[:enabled] and o[:amount].to_f.round(2) > 0.00
            @member_data[i][:loan_data][ii][:amount] = 0.00
          end
        end
      end
      @data[:member_data] = @member_data
      @billing.data = @data
      @billing.save!
      #raise @member_data.inspect
      
    end


  end
end
