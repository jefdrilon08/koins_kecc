module Billings
  class ModifyMemberRecord

    def initialize(config:)
      @config         = config
      
      @billing        = @config[:billing]
      @current_member = @config[:current_member]
      @member_records = @config[:member_records]
      @data = @billing.data.with_indifferent_access
    end

    def execute!
      m_record = @data[:records].select{ |r|
        r[:member][:id] == @current_member[:id]
      }.first

      @data[:records].each do |o|
        if o[:member][:id] == @current_member[:id]
          o[:records]= @member_records
          o[:member] = @current_member.clone
        end
      end

      @billing.update!(data: @data)

      @billing
    end
  end
end
