module Loaders
  class InsertClaimFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)
    end

    def execute!
      Claim.transaction do
        columns = [
          :id,
          :center_id,
          :branch_id, 
          :member_id,
          :claim_type,
          :prepared_by,
          :date_prepared,
          :status,
          :data 
        ]

        Claim.import columns, @data[:claim], validate: false
      end
    end
  end
end

