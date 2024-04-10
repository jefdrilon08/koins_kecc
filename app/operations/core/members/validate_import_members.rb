module Core
  module Members
    class ValidateImportMembers < ::Core::Validator
      attr_accessor :payload

      def initialize(data:)
        super()

        @data = data

        @payload = {
          data: []
        }
      end

      def execute!
        @data.each_with_index do |obj, i|
          if obj["branch_id"].blank?
            @payload[:data] << "index #{i} has no branch_id"
          end
        end

        count_errors!
      end
    end
  end
end
