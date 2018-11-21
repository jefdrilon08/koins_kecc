module Loaders
  class InsertLegalDependentsFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      LegalDependent.transaction do
        columns = [
          :id,
          :first_name,
          :middle_name,
          :last_name,
          :date_of_birth,
          :member_id,
          :relationship,
          :data
        ]

        LegalDependent.import columns, @data[:legal_dependents]
      end
    end
  end
end
