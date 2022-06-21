module Billings
  class ModifyMemberRecord
    attr_accessor :billing,
                  :current_member

    def initialize(billing:, current_member:)
      @billing        = billing
      @current_member = current_member

      @data = @billing.data.with_indifferent_access
    end

    def execute!
      m_record = @data[:records].select{ |r|
        r[:member][:id] == @current_member[:id]
      }.first

      @data[:records].each do |o|
        if o[:member][:id] == @current_member[:id]
          o[:member] = @current_member.clone
        end
      end

      @billing.update!(data: @data)

      @billing
    end
  end
end
