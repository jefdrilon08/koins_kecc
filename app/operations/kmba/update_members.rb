module Kmba
  class UpdateMembers

    def initialize(config:)
      @config = config
      @member_data = @config[:member_data]

      member = Member.where(@member_data[:identification_number]).first
    end

    def execute!

      member.update!(
        members = @member_data
      )

       Rails.logger.info(puts " Member Identification Number : #{@config[:identification_number]} Record is up to date! ")
    end
  end
end