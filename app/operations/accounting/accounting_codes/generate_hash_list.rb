module Accounting
  module AccountingCodes
    class GenerateHashList
      def initialize
        @accounting_codes = AccountingCode.select("*").order("name ASC")
        
        @data = {
          accounting_codes: []
        }
      end

      def execute!
        @accounting_codes.each do |o|
          @data[:accounting_codes] << o.to_h
        end

        @data
      end
    end
  end
end
