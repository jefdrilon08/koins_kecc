module Branches
  class FetchKbenteSummary
    def initialize(config:)
      @config = config
      @branch   = @config[:branch]
      @as_of    = @config[:as_of].try(:to_date) || Date.today

      @start_date = @as_of.beginning_of_month - 1.month
      @end_date = @as_of.end_of_month - 1.month

      @data = {
        records: []
      }

    end

    def execute!
      queryAllBranch
      number_kbente_summary
      @data
    end

    def number_kbente_summary

      @data[:records] = @result.map{ |r|
                        age               = r.fetch("age")
                        name_of_insured   = r.fetch("name_of_insured")
                        date_of_birth     = r.fetch("date_of_birth")
                        gender            = r.fetch("gender")
                        status            = r.fetch("status")
                        address           = r.fetch("address")
                        branch            = r.fetch("branch")
                        effectivity_date  = r.fetch("effectivity_date")
                        amount            = r.fetch("amount")
                        beneficiary       = r.fetch("beneficiary")
                        relationship      = r.fetch("relationship")
                        date_prepared     = r.fetch("date_prepared")
                        date_approved     = r.fetch("date_approved")

                        {
                          age: age,
                          name_of_insured: name_of_insured,
                          date_of_birth: date_of_birth,
                          gender: gender,
                          status: status,
                          address: address,
                          branch: branch,
                          effectivity_date: effectivity_date,
                          amount: amount,
                          beneficiary: beneficiary,
                          relationship: relationship,
                          effectivity_date: effectivity_date,
                          date_prepared: date_prepared,
                          date_approved: date_approved
                        }
                      }
    end

    def queryAllBranch
      @result = ActiveRecord::Base.connection.execute(<<-EOS).to_a
        SELECT
		      (r.record->'kbente_data'->>'beneficiary_age')::FLOAT::INTEGER AS age,
          r.record->'kbente_data'->>'kbente_beneficiary_name' AS name_of_insured,
          r.record->'kbente_data'->>'date_of_birth' AS date_of_birth,
          r.record->'kbente_data'->>'gender' AS gender,
          r.record->'kbente_data'->>'status' AS status,
          r.record->'kbente_data'->>'address' AS address,
          b.name as branch,
          a.date_approved as effectivity_date,
          r.record->'amount' AS amount,
          CONCAT(
            r.record->'member'->>'first_name',' ',
          r.record->'member'->>'middle_name',' ',
          r.record->'member'->>'last_name')
          as beneficiary,
          r.record->'kbente_data'->>'relationship' AS relationship,
          r.record->'kbente_data'->>'effectivity_date' AS date_prepared,
          a.date_approved as date_approved
        FROM savings_insurance_transfer_collections a
        LEFT JOIN branches b ON b.id = a.branch_id,
        jsonb_array_elements(a.data->'records') AS r(record)
        WHERE
          a.data->>'insurance_subtype' = 'K-BENTE'
          AND (a.date_approved >= '#{@start_date}' AND a.date_approved <= '#{@end_date}')
        ORDER BY
          b.name,
          a.date_approved
      EOS
    end
  end
end
