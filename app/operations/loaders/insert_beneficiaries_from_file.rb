module Loaders
  class InsertBeneficiariesFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      Beneficiary.transaction do
        columns = [
          :id,
          :member_id,
          :first_name,
          :middle_name,
          :last_name,
          :relationship,
          :date_of_birth,
          :is_primary,
          :is_deceased
        ]

        Beneficiary.import columns, @data[:beneficiaries]
      end
    end
  end
end
