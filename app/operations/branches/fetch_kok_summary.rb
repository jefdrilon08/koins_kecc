module Branches
  class FetchKokSummary
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
      number_kok_summary
      @data
    end

    def number_kok_summary

      @data[:records] = @result.map{ |r|
                        date_approved         = r.fetch("date_approved")
                        status                = r.fetch("status")
                        plan_type             = r.fetch('plan_type')
                        plan_category         = r.fetch('plan_category')
                        partner               = r.fetch('partner')
                        policy_no             = r.fetch('policy_no')
                        effectivity_date      = r.fetch('effectivity_date')
                        maturity_date         = r.fetch('maturity_date')
                        client_type           = r.fetch('client_type')
                        first_name            = r.fetch('first_name')
                        middle_name           = r.fetch('middle_name')
                        last_name             = r.fetch('last_name')
                        address               = r.fetch('address')
                        gender                = r.fetch('gender')
                        enrolled_status       = r.fetch('enrolled_status')
                        civil_status          = r.fetch('civil_status')
                        birth_date            = r.fetch('birth_date')
                        age                   = r.fetch('age')
                        premium_coverage      = r.fetch('premium_coverage')
                        mobile_no             = r.fetch('mobile_no')
                        membership_date       = r.fetch('membership_date')
                        benif_fname           = r.fetch('benif_fname')
                        benif_mname           = r.fetch('benif_mname')
                        benif_lname           = r.fetch('benif_lname')
                        benif_birth_date      = r.fetch('benif_birth_date')
                        benif_gender          = r.fetch('benif_gender')
                        benif_relationship    = r.fetch('benif_relationship')

                        {
                          date_approved: date_approved,
                          status: status,
                          plan_type: plan_type,
                          plan_category: plan_category,
                          partner: partner,
                          policy_no: policy_no,
                          effectivity_date: effectivity_date,
                          maturity_date: maturity_date,
                          client_type: client_type,
                          first_name: first_name,
                          middle_name: middle_name,
                          last_name: last_name,
                          address: address,
                          gender: gender,
                          enrolled_status: enrolled_status,
                          civil_status: civil_status,
                          birth_date: birth_date,
                          age: age,
                          premium_coverage: premium_coverage,
                          mobile_no: mobile_no,
                          membership_date: membership_date,
                          benif_fname: benif_fname,
                          benif_mname: benif_mname,
                          benif_lname: benif_lname,
                          benif_birth_date: benif_birth_date,
                          benif_gender: benif_gender,
                          benif_relationship: benif_relationship
                        }
                      }
    end

    def queryAllBranch
      @result = ActiveRecord::Base.connection.execute(<<-EOS).to_a
        SELECT
            a.date_approved,
            a.status,
          a.id,
            last_record->'kok_data'->>'plan_type' AS plan_type,
            last_record->'kok_data'->>'plan_category' AS plan_category,
            last_record->'kok_data'->>'partner' AS partner,
            last_record->'kok_data'->>'policy_no' AS policy_no,
            last_record->'kok_data'->>'effectivity_date' AS effectivity_date,
            last_record->'kok_data'->>'maturity_date' AS maturity_date,
            last_record->'kok_data'->>'client_type' AS client_type,
            last_record->'kok_data'->>'first_name' AS first_name,
            last_record->'kok_data'->>'middle_name' AS middle_name,
            last_record->'kok_data'->>'last_name' AS last_name,
            last_record->'kok_data'->>'address' AS address,
            last_record->'kok_data'->>'gender' AS gender,
            last_record->'kok_data'->>'enrolled_status' AS enrolled_status,
            last_record->'kok_data'->>'civil_status' AS civil_status,
            last_record->'kok_data'->>'birth_date' AS birth_date,
            last_record->'kok_data'->>'age' AS age,
            last_record->'kok_data'->>'premium_coverage' AS premium_coverage,
            last_record->'kok_data'->>'mobile_no' AS mobile_no,
            last_record->'kok_data'->>'membership_date' AS membership_date,
            last_record->'kok_data'->>'benif_fname' AS benif_fname,
            last_record->'kok_data'->>'benif_mname' AS benif_mname,
            last_record->'kok_data'->>'benif_lname' AS benif_lname,
            last_record->'kok_data'->>'benif_birth_date' AS benif_birth_date,
            last_record->'kok_data'->>'benif_gender' AS benif_gender,
            last_record->'kok_data'->>'benif_relationship' AS benif_relationship
        FROM
            insurance_loan_bundle_enrollments a
        LEFT JOIN
            branches b ON b.id = a.branch_id,
            LATERAL (
                SELECT r.value AS last_record
                FROM jsonb_array_elements(a.data->'records') WITH ORDINALITY r(value, ordinality)
                ORDER BY ordinality DESC
                LIMIT 1
            ) AS last_record
        WHERE
            (a.date_approved >= '#{@start_date}' AND a.date_approved <= '#{@end_date}')
        ORDER BY
            b.name,
            a.date_approved
      EOS
    end
  end
end
