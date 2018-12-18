module Loaders
  class InsertMembersFromFile < InsertFromFile
    def initialize(params:)
      super(params: params)

      # avoid duplicates
      unique_members  = []

      @data[:members].each do |o|
        if Member.where(id: o[:id]).size == 0
          unique_members << o
        end
      end
    end

    def execute!
      Member.transaction do
        columns = [
          :id,
          :center_id,
          :branch_id,
          :first_name,
          :middle_name,
          :last_name,
          :gender,
          :date_of_birth,
          :civil_status,
          :home_number,
          :mobile_number,
          :processed_by,
          :approved_by,
          :identification_number,
          :place_of_birth,
          :status,
          :member_type,
          :religion,
          :insurance_status,
          :data,
          :date_resigned,
          :meta
        ]

        #Member.import columns, @data[:members], validate: false
        Member.import colums, unique_mebers, validate: false
      end
    end
  end
end
