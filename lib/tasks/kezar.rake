namespace :kezar do

  # New API for KEZAR
  task :member_api => :environment do
    email           = "kmba-manual-upload@kezar.co"
    password        = "oQEVaTMGzNls"
    end_point       = "https://auth-jdyjiucdcq-uc.a.run.app/auth/loginAdmin"

    credentials = {
      email: email,
      password: password
    }

    Rails.logger.info(puts("Logging in #{end_point} . . . "))
    login = HTTParty.post(
      end_point,
      body: credentials.to_json,
      :headers => { 'Content-Type' => 'application/json'}
    )

    # Rails.logger.info(puts(login))
    # declaring the accessToken to a variable access_token
    access_token = login['accessToken']
    # setting up the access token to an environment 
    ENV["ACCESS_TOKEN"] = access_token

    Rake::Task['kezar:member_body_api'].invoke
  end

  task :member_body_api => :environment do
    #--------------Start Declarations--------------# 
      # Set the batch size (number of records per batch)
      batch_size              = 500
      # Initialize variables for pagination
      offset                  = 0
      total_records           = 0 
      # Define a flag to indicate whether to continue fetching more batches
      fetch_more_batches      = true
      end_point               = ENV['KEZAR_API_SEND_MEMBERDATA'] || "https://account-jdyjiucdcq-uc.a.run.app/account/uploadDocument"
      is_batch                = ENV["BATCH"] || true
      # retrieve the access token to an environment 
      bearer_token            = ENV["ACCESS_TOKEN"]
    # --------------End Declarations--------------# 

    while fetch_more_batches

      sql_query = <<-SQL
        WITH RankedLegalDependents AS (
            SELECT
                g.*,
                ROW_NUMBER() OVER (PARTITION BY g.member_id ORDER BY g.id) AS dependent_rank
            FROM
                legal_dependents g
        )
        SELECT
          a.id,
          CASE 
            WHEN a.identification_number IS NULL then ''
            ELSE a.identification_number
          END as blip_number,
          CASE
            WHEN a.first_name IS NOT NULL OR a.middle_name IS NOT NULL OR a.last_name IS NOT NULL THEN CONCAT(a.first_name, ' ', a.middle_name, ' ', a.last_name)
            ELSE ''
          END AS full_name,
          CASE
            WHEN a.data->>'recognition_date' IS NULL THEN ''
            ELSE TO_CHAR((a.data->>'recognition_date')::date, 'YYYY-MM-DD"T"HH24:MI:SS')
          END as blip_effectivity_date,
          CASE
            WHEN b.name IS NOT NULL THEN b.name
          ELSE ''
          END AS branch_name,
          CASE
            WHEN c.name IS NOT NULL THEN c.name
          ELSE ''
          END AS center_name,
          CONCAT(f.first_name, ' ', f.middle_name, ' ', f.last_name) as recruitedBy,
          CASE 
            WHEN a.first_name IS NULL then ''
            ELSE a.first_name
          END AS first_name,
          CASE 
            WHEN a.middle_name IS NULL then ''
            ELSE a.middle_name
          END AS middle_name,
          CASE 
            WHEN a.last_name IS NULL then ''
            ELSE a.last_name
          END AS last_name,
          CASE
            WHEN LENGTH(a.middle_name) <= 2 THEN a.middle_name
            WHEN LENGTH(a.middle_name) > 2 THEN CONCAT(SUBSTRING(a.middle_name FROM 1 FOR 1), '.')
            ELSE 'N/A'
          END AS suffix,
          a.gender AS gender,
          a.civil_status AS marital_status,
          CASE
            WHEN a.date_of_birth IS NULL THEN ''
            ELSE TO_CHAR(a.date_of_birth, 'YYYY-MM-DD"T"HH24:MI:SS')
          END AS birthday,
          CASE
            WHEN 
              a.place_of_birth IS NULL THEN ''
              ELSE a.place_of_birth
          END AS place_of_birth,
          CASE 
            WHEN a.data->'address'->>'province' IS NULL THEN ''
          ELSE a.data->'address'->>'province'
          END AS province,
          CASE 
            WHEN a.data->'address'->>'city' IS NULL THEN ''
            ELSE a.data->'address'->>'city'
          END AS city,
          CASE 
            WHEN a.data->'address'->>'street' IS NULL THEN ''
            ELSE a.data->'address'->>'street'
          END AS street,
          CASE 
            WHEN a.mobile_number IS NULL THEN '' 
            ELSE a.mobile_number
          END AS contact_number,
          CASE WHEN a.data->'government_identification_numbers'->>'tin_number' IS NULL THEN '' ELSE a.data->'government_identification_numbers'->>'tin_number' END AS tin_number,  
          CASE WHEN a.data->'government_identification_numbers'->>'sss_number' IS NULL THEN '' ELSE a.data->'government_identification_numbers'->>'sss_number' END AS sss_number,
          CASE WHEN a.data->'spouse'->>'first_name' IS NULL THEN '' ELSE a.data->'spouse'->>'first_name' END AS spouse_first_name,
          CASE WHEN a.data->'spouse'->>'middle_name' IS NULL THEN '' ELSE a.data->'spouse'->>'middle_name' END AS spouse_middle_name,
          CASE WHEN a.data->'spouse'->>'last_name' IS NULL THEN '' ELSE a.data->'spouse'->>'last_name' END AS spouse_last_name,
          CASE WHEN a.data->'spouse'->>'date_of_birth' IS NULL THEN '' ELSE a.data->'spouse'->>'date_of_birth' END AS spouse_birthday,
          MAX(CASE 
            WHEN dependent_rank = 1 AND (g.first_name IS NOT NULL OR g.middle_name IS NOT NULL OR g.last_name IS NOT NULL)  THEN CONCAT(g.first_name, ' ', g.middle_name, ' ', g.last_name) 
            ELSE ''
          END) AS first_dependent_name,
          MAX(CASE 
            WHEN dependent_rank = 1 AND g.relationship IS NOT NULL THEN g.relationship 
            ELSE ''
          END) AS first_relationship,
          MAX(CASE 
            WHEN dependent_rank = 1 AND g.date_of_birth IS NOT NULL THEN g.date_of_birth::text 
            ELSE ''
          END) AS first_date_of_birth,
          MAX(CASE 
            WHEN dependent_rank = 2 AND (g.first_name IS NOT NULL OR g.middle_name IS NOT NULL OR g.last_name IS NOT NULL) THEN CONCAT(g.first_name, ' ', g.middle_name, ' ', g.last_name) 
            ELSE ''
          END) AS second_dependent_name,
          MAX(CASE 
            WHEN dependent_rank = 2 AND g.relationship IS NOT NULL THEN g.relationship
            ELSE ''
          END) AS second_relationship,
          MAX(CASE 
            WHEN dependent_rank = 2 AND g.date_of_birth IS NOT NULL THEN g.date_of_birth::text 
            ELSE ''
          END) AS second_date_of_birth,
          MAX(CASE 
            WHEN dependent_rank = 3 AND (g.first_name IS NOT NULL OR g.middle_name IS NOT NULL OR g.last_name IS NOT NULL) THEN CONCAT(g.first_name, ' ', g.middle_name, ' ', g.last_name) 
            ELSE ''
          END) AS third_dependent_name,
          MAX(CASE 
            WHEN dependent_rank = 3 AND g.relationship IS NOT NULL THEN g.relationship
            ELSE ''
          END) AS third_relationship,
          MAX(CASE 
            WHEN dependent_rank = 3 AND g.date_of_birth IS NOT NULL THEN g.date_of_birth::text 
            ELSE ''
          END) AS third_date_of_birth,
          MAX(CASE 
            WHEN dependent_rank = 4 AND (g.first_name IS NOT NULL OR g.middle_name IS NOT NULL OR g.last_name IS NOT NULL) THEN CONCAT(g.first_name, ' ', g.middle_name, ' ', g.last_name) 
            ELSE ''
          END) AS fourth_dependent_name,
          MAX(CASE 
            WHEN dependent_rank = 4 AND g.relationship IS NOT NULL THEN g.relationship
            ELSE ''
          END) AS fourth_relationship,
          MAX(CASE 
            WHEN dependent_rank = 4 AND g.date_of_birth IS NOT NULL THEN g.date_of_birth::text 
            ELSE ''
          END) AS fourth_date_of_birth,
          MAX(CASE 
            WHEN dependent_rank = 5 AND (g.first_name IS NOT NULL OR g.middle_name IS NOT NULL OR g.last_name IS NOT NULL) THEN CONCAT(g.first_name, ' ', g.middle_name, ' ', g.last_name) 
            ELSE ''
          END) AS fifth_dependent_name,
          MAX(CASE 
            WHEN dependent_rank = 5 AND g.relationship IS NOT NULL THEN g.relationship
            ELSE ''
          END) AS fifth_relationship,
          MAX(CASE 
            WHEN dependent_rank = 5 AND g.date_of_birth IS NOT NULL THEN g.date_of_birth::text 
            ELSE ''
          END) AS fifth_date_of_birth,
          MAX(CASE 
            WHEN h.is_primary = 'true' AND h.first_name IS NOT NULL AND h.middle_name IS NOT NULL AND h.last_name IS NOT NULL THEN CONCAT(h.first_name, ' ', h.middle_name, ' ', h.last_name) 
            ELSE ''
          END) AS primary_name_beneficiary,
          MAX(CASE 
            WHEN h.is_primary = 'true' AND h.relationship IS NOT NULL THEN h.relationship 
            ELSE ''
          END) AS primary_relationship_beneficiary,
          MAX(CASE 
            WHEN h.is_primary = 'true' AND h.date_of_birth IS NOT NULL THEN to_char(h.date_of_birth, 'YYYY-MM-DD"T"HH24:MI:SS')
            ELSE ''
          END) AS primary_date_of_birth_beneficiary,
          MAX(CASE 
            WHEN h.is_primary = 'false' OR h.is_primary IS NULL AND (h.first_name IS NOT NULL OR h.middle_name IS NOT NULL OR h.last_name IS NOT NULL) THEN CONCAT(h.first_name, ' ', h.middle_name, ' ', h.last_name)
            ELSE ''
          END) AS secondary_name_beneficiary,
          MAX(CASE 
            WHEN h.is_primary = 'false' OR h.is_primary IS NULL AND h.relationship IS NOT NULL THEN h.relationship 
            ELSE ''
          END) AS secondary_relationship_beneficiary,
          MAX(CASE 
            WHEN h.is_primary = 'false' OR h.is_primary IS NULL AND h.date_of_birth IS NOT NULL THEN to_char(h.date_of_birth, 'YYYY-MM-DD"T"HH24:MI:SS')
            ELSE ''
          END) AS secondary_date_of_birth_beneficiary
        FROM members a
        LEFT JOIN branches b ON b.id = a.branch_id 
        LEFT JOIN clusters c ON c.id = b.cluster_id
        LEFT JOIN areas d ON d.id = c.area_id
        LEFT JOIN centers e ON e.id = a.center_id
        LEFT JOIN referrers f ON f.id = a.referrer_id
        LEFT JOIN RankedLegalDependents g ON g.member_id = a.id
        LEFT JOIN beneficiaries h ON h.member_id = a.id

        WHERE a.branch_id = '3a74c7d5-54a5-4eec-826d-ab81f76ae31a'
        AND a.insurance_status = 'inforce'
        AND a.identification_number IN ('HOKMBA-A01848', 'C1KMBA-A01182', 'HOKMBA-HO00082')
        -- AND a.identification_number = 'HOKMBA-HO00082'
        GROUP BY a.id, a.identification_number, a.first_name, a.middle_name, a.last_name, d.name, b.name, e.name, f.first_name, f.middle_name, f.last_name, c.name, b.name
        ORDER BY branch_name
        OFFSET #{offset} ROWS FETCH NEXT #{batch_size} ROWS ONLY
      SQL

      results = ActiveRecord::Base.connection.execute(sql_query)

      # Increment offset for the next batch
      offset += batch_size

      # Check if we should fetch another batch
      fetch_more_batches = results.count == batch_size

      # Update the total number of records processed so far
      total_records += results.count

      processed_member_ids = Set.new

      results.each do |o|
        blip_number                           = o['blip_number']
        full_name                             = o['full_name']
        blip_effectivity_date                 = o['blip_effectivity_date']
        branch_name                           = o['branch_name']
        center_name                           = o['center_name']
        first_name                            = o['first_name']
        middle_name                           = o['middle_name']
        last_name                             = o['last_name']
        suffix                                = o['suffix']
        gender                                = o['gender']
        marital_status                        = o['marital_status']
        birthday                              = o['birthday']
        place_of_birth                        = o['place_of_birth']
        province                              = o['province']
        city                                  = o['city']
        street                                = o['street']
        contact_number                        = o['contact_number']
        tin_number                            = o['tin_number']  
        sss_number                            = o['sss_number'] 
        spouse_first_name                     = o['spouse_first_name']
        spouse_middle_name                    = o['spouse_middle_name']
        spouse_last_name                      = o['spouse_last_name']
        spouse_birthday                       = o['spouse_birthday']
        first_dependent_name                  = o['first_dependent_name']
        first_relationship                    = o['first_relationship']
        first_date_of_birth                   = o['first_date_of_birth']
        second_dependent_name                 = o['second_dependent_name']
        second_relationship                   = o['second_relationship']
        second_date_of_birth                  = o['second_date_of_birth']
        third_dependent_name                  = o['third_dependent_name']
        third_relationship                    = o['third_relationship'] 
        third_date_of_birth                   = o['third_date_of_birth']
        fourth_dependent_name                 = o['fourth_dependent_name']
        fourth_relationship                   = o['fourth_relationship']
        fourth_date_of_birth                  = o['fourth_date_of_birth']
        fifth_dependent_name                  = o['fifth_dependent_name']
        fifth_relationship                    = o['fifth_relationship']
        fifth_date_of_birth                   = o['fifth_date_of_birth']
        primary_name_beneficiary              = o['primary_name_beneficiary']
        primary_relationship_beneficiary      = o['primary_date_of_birth_beneficiary']
        primary_date_of_birth_beneficiary     = o['primary_date_of_birth_beneficiary']
        secondary_name_beneficiary            = o['secondary_name_beneficiary']
        secondary_relationship_beneficiary    = o['secondary_relationship_beneficiary']
        secondary_date_of_birth_beneficiary   = o['secondary_date_of_birth_beneficiary']


        member_records = {
          userId: '',
          data: {
            accountNumber: blip_number,
            fullname: full_name,
            type: 'blipMembership',
            zForm: [
              {
               id: '01branchAndCenter',
               response: [ 'KMBA', branch_name, center_name ]
              },
              { id: 'blipEffectivityDate', response: blip_effectivity_date },
              { id: '02recruitedBy', response: ''},
              { id: '03firstName', response: first_name },
              { id: '04middleName', response: middle_name },
              { id: '05lastName', response: last_name },
              { id: '52suffix', response: suffix },
              { id: '53suffixText', response: '' },
              { id: '06gender', response: gender }, 
              { id: '07maritalStatus', response: marital_status },
              { id: '08birthday', response: birthday },
              { id: '09placeOfBirth', response: place_of_birth },
              { id: '10address', 
                response: [ province, city, street ] 
              },
              { id: '11contactNumber', response: contact_number },
              { id: '12occupation', response: ''},
              { id: '13workAddress', response: '' },
              { id: '14tinSssGsis', response: [ tin_number, sss_number, '' ] },
              { id: '15spouseDetailsHeader', response: '' },
              { id: '16spouseFirstName', response: spouse_first_name },
              { id: '17spouseMiddleName', response: spouse_middle_name },
              { id: '18spouseLastName', response: spouse_last_name },
              { id: '19spouseBirthday', response: spouse_birthday },
              { id: '20spousePlaceOfBirth', response: '' },
              { id: '21spousePlaceOfBirthAddress', response: '' },       
              { id: '22spouseContactNumber', response: '' },
              { id: '23spouseOccupation', response: '' },
              { id: '24spouseWorkAddress', response: '' },
              { id: '25spouseTinSssGsis', response: '' },
              { id: '26legalDependentsHeader', response: '' },
              { id: '27firstDependentHeader', response: '' },
              {
                id: '28firstDependent',
                response: [ first_dependent_name, first_relationship, first_date_of_birth ]
              },
              { id: '29secondDependentHeader', response: '' },
              { id: '30secondDependent', 
                response: [ second_dependent_name, second_relationship, second_date_of_birth ] 
              },

              { id: '31thirdDependentHeader', response: '' },
              { id: '32thirdDependent', 
                response: [ third_dependent_name, third_relationship, third_date_of_birth ] 
              },
              { id: '33fourthDependentHeader', response: '' },
              { id: '34fourthDependent', 
                response: [ fourth_dependent_name, fourth_relationship, fourth_date_of_birth ] 
              },
              { id: '35fifthDependentHeader', response: '' },
              { id: '36fifthDependent', 
                response: [ fifth_dependent_name, fifth_relationship, fifth_date_of_birth ] 
              },
              { id: '38primaryBeneficiaryHeader', response: '' },
              {
                id: '39primaryBeneficiary',
                response: [ primary_name_beneficiary, primary_relationship_beneficiary, primary_date_of_birth_beneficiary ]
              },
              { id: '40secondaryBeneficiaryHeader', response: '' },
              { id: '41secondaryBeneficiary' ,response: [ secondary_name_beneficiary, secondary_relationship_beneficiary, secondary_date_of_birth_beneficiary ] },
              { id: '42applicantSelfieHeader', response: '' },
              { id: '43applicantSelfie', response: '' },
              { id: '44attachmentsHeader', response: '' },
              { id: '45GovernmentIssuedId', response: '' },
              { id: '46singleBirthCertificate', response: '' },
              { id: '47mayKinakasamaAffidavitOfCohabitation', response: ''},
              { id: '48ChildBirthCertificate', response: '' },
              { id: '49kasalMarriageContract', response: '' },
              { id: '50acknowledgementHeader', response: '' },
              { id: '51signatureViaApp', response: '' },
              { id: '52signatureViaUpload', response: '' }
            ]
          }
        }
        
        next if processed_member_ids.include?(blip_number)
        payload = member_records
        Rails.logger.info(puts payload.to_json)

        # raise payload.inspect
        
        if is_batch.present?
          Rails.logger.info(puts("Posting to #{end_point}..."))
          result = HTTParty.post(
                     end_point,
                     body: payload.to_json,
                     :headers => { 
                        'Content-Type' => 'application/json', 
                        'Authorization' => "Bearer #{bearer_token}"
                     }
                  )
          Rails.logger.info(puts(result))

          processed_member_ids.add(blip_number)
        end
      end
    end
    puts "Total records processed: #{total_records}"
  end

  task :blip_claims_api => :environment do
    email           = "kmba-manual-upload@kezar.co"
    password        = "oQEVaTMGzNls"
    end_point       = "https://auth-jdyjiucdcq-uc.a.run.app/auth/loginAdmin"

    credentials = {
      email: email,
      password: password
    }

    Rails.logger.info(puts("Logging in #{end_point} . . . "))
    login = HTTParty.post(
      end_point,
      body: credentials.to_json,
      :headers => { 'Content-Type' => 'application/json'}
    )

    # Rails.logger.info(puts(login))
    # declaring the accessToken to a variable access_token
    access_token = login['accessToken']
    # setting up the access token to an environment 
    ENV["ACCESS_TOKEN"] = access_token

    Rake::Task['kezar:blip_claims_body_api'].invoke
  end

  task :blip_claims_body_api => :environment do
    #--------------Start Declarations--------------# 
      # Set the batch size (number of records per batch)
      batch_size              = 500
      # Initialize variables for pagination
      offset                  = 0
      total_records           = 0
      # Define a flag to indicate whether to continue fetching more batches
      fetch_more_batches      = true
      end_point               = ENV['KEZAR_API_SEND_MEMBERDATA'] || "https://account-jdyjiucdcq-uc.a.run.app/account/uploadDocument"
      is_batch                = ENV["BATCH"] || true
      # retrieve the access token to an environment 
      bearer_token            = ENV["ACCESS_TOKEN"]
    # --------------End Declarations--------------# 

    while fetch_more_batches

      sql_query = <<-SQL
        SELECT
          a.id,
          CASE
            WHEN b.identification_number IS NULL THEN ''
            ELSE b.identification_number
          END AS blip_no,
          CONCAT (b.first_name,' ',b.middle_name,' ',b.last_name) as members_full_name,
          CASE
            WHEN b.data->>'recognition_date' IS NULL THEN ''
            ELSE b.data->>'recognition_date'
          END as date_of_membership,
          CASE
            WHEN c.name IS NULL THEN ''
            ELSE c.name
          END as branch,
          CASE
            WHEN d.name IS NULL THEN ''
            ELSE d.name
          END as center,
          CASE
            WHEN a.data->>'category_of_cause_of_death_tpd_accident' = 'Accidental Death' 
              OR a.data->>'category_of_cause_of_death_tpd_accident' = 'Motor Vehicular' 
              OR a.data->>'category_of_cause_of_death_tpd_accident' = 'Motor Vehicular Accident' 
            THEN 'Abiso ng Pagkamatay dahil sa Aksidente (Notice of Death due to Accident)'
            
            WHEN a.data->>'category_of_cause_of_death_tpd_accident' = 'Gastro Intestinal' 
              OR a.data->>'category_of_cause_of_death_tpd_accident' = 'Hematological'
                    OR a.data->>'category_of_cause_of_death_tpd_accident' = 'Neurogical'
                    OR a.data->>'category_of_cause_of_death_tpd_accident' = 'Cardiovascular'
                    OR a.data->>'category_of_cause_of_death_tpd_accident' = 'Neurological'
                    OR a.data->>'category_of_cause_of_death_tpd_accident' = 'Respiratory'
                    OR a.data->>'category_of_cause_of_death_tpd_accident' = 'Gynecological'
                THEN 'Abiso ng Natural na Pagkamatay (Notice of Natural Death)'
            
            ELSE ''
          END as application_type, 
          a.data->>'beneficiary' as claimant_name,
          a.data->>'classification_of_insured' as relation_to_member_of_deceased_disabled,
          a.data->>'name_of_insured' as name_of_deceased_disabled,
          a.data->>'date_of_birth' as date_of_birth_deceased_disabled,
          CASE
            WHEN a.data->>'cause_of_death_tpd_accident' IS NULL THEN ''
            ELSE a.data->>'cause_of_death_tpd_accident'
          END as cause_of_death_disability,
          a.data->>'date_of_death_tpd_accident' as date_of_death_disability,
          CASE 
            WHEN a.data->>'category_of_cause_of_death_tpd_accident' = 'Motor Vehicular' OR a.data->>'category_of_cause_of_death_tpd_accident' = 'Motor Vehicular Accident'
            THEN 'YES'
            ELSE 'NO'
          END AS motor_vehicular_accident_hospitalization

        FROM claims a  
        LEFT JOIN members b ON b.id = a.member_id
        LEFT JOIN branches c ON c.id = a.branch_id
        LEFT JOIN centers d ON d.id = a.center_id

        WHERE a.claim_type = 'BLIP'
        AND a.branch_id = '3a74c7d5-54a5-4eec-826d-ab81f76ae31a'
  
      SQL

      results = ActiveRecord::Base.connection.execute(sql_query)
      # raise results.to_json.inspect

      # Increment offset for the next batch
      offset += batch_size

      # Check if we should fetch another batch
      fetch_more_batches = results.count == batch_size

      # Update the total number of records processed so far
      total_records += results.count

      processed_member_ids = Set.new

      results.each do |o|
        blip_no                                            = o['blip_no']
        members_full_name                                  = o['members_full_name']
        date_of_membership                                 = o['date_of_membership']
        branch                                             = o['branch']
        center                                             = o['center']
        application_type                                   = o['application_type']
        claimant_name                                      = o['claimant_name']
        relation_to_member_of_deceased_disabled            = o['relation_to_member_of_deceased_disabled']
        name_of_deceased_disabled                          = o['name_of_deceased_disabled']
        date_of_birth_deceased_disabled                    = o['date_of_birth_deceased_disabled']
        cause_of_death_disability                          = o['cause_of_death_disability']
        date_of_death_disability                           = o['date_of_death_disability']
        motor_vehicular_accident_hospitalization           = o['motor_vehicular_accident_hospitalization']
        
        member_records = {
          userId: '',
          data: {
            accountNumber: blip_no,
            fullname: members_full_name,
            type: 'blipClaim',
            zForm: [
              { id: '01blipNo', response: blip_no },
              { id: '02memberFullName', response: members_full_name },
              { id: '03dateOfMembership', response: date_of_membership},
              { id: '04branchAndCenter', response: [ 'KMBA', branch, center] },
              { id: '06applicationType', response: application_type },
              { id: '08claimantName', response: claimant_name },
              { id: '09claimantContactNumber', response: '' },
              { id: '10claimantEmail', response: '' },
              { id: '11claimantType', response: '' },
              { id: '12claimantRelationtoMember', response: '' },

              { id: '14relationToMemberOfDeceasedDisabled', response: relation_to_member_of_deceased_disabled },
              { id: '15nameOfDeceasedDisabled', response: name_of_deceased_disabled },
              { id: '16dateOfBirthOfDeceasedDisabled', response: date_of_birth_deceased_disabled },

              { id: '17maritalStatusOfDeceasedDisabled', response: '' },
              { id: '18homeAddressOfDeceasedDisabled', response: '' },

              { id: '19causeOfDeathDisability', response: cause_of_death_disability },
              { id: '20dateOfDeathDisability', response: date_of_death_disability },
              { id: '21motorVehicularAccidentHospitalization', response: motor_vehicular_accident_hospitalization },

              { id: '22nameOfHospital', response: '' },
              { id: '23admissionDate', response: '' },
              { id: '24dischargeDate', response: '' },
              { id: '25doctorName', response: '' },
              { id: '26hospitalFee', response: '' },
              { id: '28claimantGovernmentIssuedId', response: '' },
              { id: '29memberDeathCertificate', response: '' },

              { id: '30accidentIncidentPoliceReport', response: '' },
              { id: '31medicalDoctorCertificateOfDisability', response: '' },
              { id: '32childClaimantBirthCertificate', response: '' },
              { id: '33spouseMarriageCertificate', response: '' },
              { id: '34memberBirthCertificate', response: '' },
              { id: '35memberOriginalMembershipCertificate', response: '' },
              { id: '36memberAffidavitOfLoss', response: '' },
              { id: '38signatureViaApp', response: '' }
            ]
          }
        }
        
        next if processed_member_ids.include?(blip_no)
        payload = member_records
        Rails.logger.info(puts payload.to_json)

        # raise payload.inspect
        
        if is_batch.present?
          Rails.logger.info(puts("Posting to #{end_point}..."))
          result = HTTParty.post(
                     end_point,
                     body: payload.to_json,
                     :headers => { 
                        'Content-Type' => 'application/json', 
                        'Authorization' => "Bearer #{bearer_token}"
                     }
                  )
          Rails.logger.info(puts(result))

          processed_member_ids.add(blip_no)
        end
      end
    end
    puts "Total records processed: #{total_records}"
  end

  task :payment_api => :environment do
    email           = "kmba-manual-upload@kezar.co"
    password        = "oQEVaTMGzNls"
    end_point       = "https://auth-jdyjiucdcq-uc.a.run.app/auth/loginAdmin"

    credentials = {
      email: email,
      password: password
    }

    Rails.logger.info(puts("Logging in #{end_point} . . . "))
    login = HTTParty.post(
      end_point,
      body: credentials.to_json,
      :headers => { 'Content-Type' => 'application/json'}
    )

    # Rails.logger.info(puts(login))
    # declaring the accessToken to a variable access_token
    access_token = login['accessToken']
    # setting up the access token to an environment 
    ENV["ACCESS_TOKEN"] = access_token
    # raise access_token.inspect
    Rake::Task['kezar:payment_body_api'].invoke
  end

  task :payment_body_api => :environment do
    #--------------Start Declarations--------------# 
      # Set the batch size (number of records per batch)
      batch_size              = 500
      # Initialize variables for pagination
      offset                  = 0
      total_records           = 0
      # Define a flag to indicate whether to continue fetching more batches
      fetch_more_batches      = true
      end_point               = ENV['KEZAR_API_SEND_PAYMENTS'] || "https://payment-jdyjiucdcq-uc.a.run.app/payment/KMBA/upload"
      is_batch                = ENV["BATCH"] || true
      transaction_type        = 'deposit'
      is_interest             = 'false'
      insurance_status        = 'inforce'
      status                  = 'active'
      account_subtype         = 'Life Insurance Fund','Retirement Fund'
      branches                = '3a74c7d5-54a5-4eec-826d-ab81f76ae31a'
      member_id               = '0a30de26-163b-48ac-8d90-55db208b240a'

      # retrieve the access token to an environment 
      bearer_token            = ENV["ACCESS_TOKEN"]
    # --------------End Declarations--------------# 

    account_transactions = AccountTransaction.select(
      " 
        account_transactions.id,
        account_transactions.amount as amount,
        account_transactions.id AS reference_number,
        'Bank Transfer' AS source,
        member_accounts.account_subtype as type,
        account_transactions.transacted_at as payment_date,
        members.identification_number as account_number,
        CONCAT(members.first_name,' ',members.middle_name,' ',members.last_name) as full_name,
        'KMBA' as tier1,
        branches.name as tier2,
        centers.name as tier3
      "
    ).joins(
      "
        LEFT JOIN member_accounts ON member_accounts.id = account_transactions.subsidiary_id
        LEFT JOIN members ON members.id = member_accounts.member_id 
        LEFT JOIN branches ON branches.id = members.branch_id
        LEFT JOIN centers ON centers.id = members.center_id
      "
    ).where(
        "
          account_transactions.transaction_type = ?
          AND (account_transactions.data->>'is_interest' = ? OR account_transactions.data->>'is_interest' IS NULL) 
          AND members.insurance_status = ? 
          AND members.status = ? 
          AND member_accounts.account_subtype IN (?)
          AND branches.id IN (?)
          AND members.id = ?
          AND 
            CASE
              WHEN members.data->'resignation_records' IS NULL THEN
                DATE(account_transactions.transacted_at) >= DATE(members.data->>'recognition_date')  
              WHEN ((members.data->'resignation_records'->2->>'date_resigned' IS NOT NULL) AND (members.data->'resignation_records'->1->>'date_resigned' IS NOT NULL) AND (members.data->'resignation_records'->0->>'date_resigned' IS NOT NULL)) THEN
                  DATE(account_transactions.transacted_at) >= DATE(members.data->'resignation_records'->2->>'date_resigned')
              WHEN ((members.data->'resignation_records'->1->>'date_resigned' IS NOT NULL) AND (members.data->'resignation_records'->0->>'date_resigned' IS NOT NULL)) THEN
                  DATE(account_transactions.transacted_at) >= DATE(members.data->'resignation_records'->1->>'date_resigned')
              WHEN members.data->'resignation_records'->0->>'date_resigned' IS NOT NULL THEN
                DATE(account_transactions.transacted_at) >= DATE(members.data->'resignation_records'->0->>'date_resigned')
            END
        ",
        transaction_type,
        is_interest,
        insurance_status,
        status,
        account_subtype,
        branches,
        member_id 
    ).find_in_batches(:batch_size => 50) do |group|

      Rails.logger.info(puts "Uploading #{group.size} transactions...")

      payments = group.map{ |o|
        {
          details: {
            amount: o.amount,
            referenceNumber: o.reference_number,
            source: o.source,
            type: o.type,
            paymentDate: o.payment_date
          },
          payor: {
            accountNumber: o.account_number,
            fullName: o.full_name,
            tier1: o.tier1,
            tier2: o.tier2,
            tier3: o.tier3
          }
        }
      }

      total = payments.count
      payload = {data: payments}
      Rails.logger.info(puts payload.to_json)

      # raise payload.inspect
      if is_batch.present?
        Rails.logger.info(puts("Posting to #{end_point}..."))
        result = HTTParty.post(
                   end_point,
                   body: payload.to_json,
                   :headers => { 
                    'Content-Type' => 'application/json', 
                    'Authorization' => "Bearer #{bearer_token}"  
                  },
                  timeout: 120
                )
        Rails.logger.info(puts(result))
        Rails.logger.info(puts(total))
      else
        payload.each do |p|
          Rails.logger.info(puts("Posting to #{end_point}..."))
          result  = HTTParty.post(
                      end_point,
                      body: p.to_json,
                      :headers => { 
                        'Content-Type' => 'application/json', 
                        'Authorization' => "Bearer #{bearer_token}"
                      },
                      timeout: 120
                    )
          Rails.logger.info(puts(result))
        end
      end
    end
  end


  # FOR PAYMENTS API 
  task :send_payments => :environment do
    start_date    = ENV["START_DATE"] || Date.today - 1.month
    end_date      = ENV["END_DATE"] || Date.today
    endpoint      = ENV['KEZAR_API_SEND_PAYMENTS'] || "https://usentral1-rms-kmba.cloudfunctions.net/api/payment/batch/upload"
    is_batch      = ENV["BAH"] || true
    
    account_type      = "INSURANCE"
    account_btypes  = ["Life Insurance Fund", "Retirent Fund"]

    account_transactions = AccountTransaction.select(     
    "account_transactions.id,
     members.identification_number, 
     account_transactions.transacted_at
       account_transactions.amount,       
       member_accounts.account_subtype, 
       account_transactns.id, 
       branches.name AS branch_name"
    ).joins(
      "INN JOIN member_accounts ONember_accounts.id = acunt_transactions.subsidiary_id INNER JOIN mbers ON memrs.id   end = member_accounts.member_id INNER JOIN branches ON branches.id = member_accounts.branch_id"
    ).where(
      "member_accounts.account_type = ? AND member_accounts.account_subtype IN (?) AND DATE(transacted_at) >= ? AND DATE(transacted_at) <= ? ",
      account_type,
      account_subtypes,
      start_date,
      end_date,
    ).find_in_batches(:batch_size => 500) do |group|

      Rails.logger.info(puts "Uploading #{group.size} transactions...")
      records = group.map{ |o|
        {
          memberNumber: o.identification_number,
          amountPaid: o.amount,
          branch: o.branch_name,
          datePlacedPayment: o.transacted_at.strftime("%Y-%m-%d"),
          paymentType: o.account_subtype,
          paymentRefNo: o.id,
          paymentChannel: "Bank Transfer",
          orDate: o.transacted_at.strftime("%Y-%m-%d"),
          description: "test",
          externalRef: o.id
        }
      }

      Rails.logger.info(puts records.to_json)

      payload = records

      if is_batch.present?
        Rails.logger.info(puts("Posting to #{endpoint}..."))
        result = HTTParty.post(
                   endpoint,
                   body: payload.to_json,
                   :headers => { 'Content-Type' => 'application/json' }
                )
        Rails.logger.info(puts(result))
    
      else
        payload.each do |p|
          Rails.logger.info(puts("Posting to #{endpoint}..."))
          result  = HTTParty.post(
                      endpoint,
                      body: p.to_json,
                      :headers => { 'Content-Type' => 'application/json' }
                    )

          Rails.logger.info(puts(result))
        end
      end
    end
  end

  #API Members
  task send_members: :environment do
    start_date        = ENV["START_DATE"]  || Date.today - 1.month
    end_date          = ENV["END_DATE"] || Date.today
    is_batch          = ENV["BATCH"] || true
    end_point         = ENV['KEZAR_API_SEND_MEMBERDATA'] || "https://us-central1-rms-kmba.cloudfunctions.net/apiTest/membership/batch/upload"

    memberdata = Member.select(
    "
      members.id,
      members.identification_number AS membernumber,
      members.last_name AS applicantlastname,
      members.first_name AS applicantfirstname,
      members.middle_name AS applicantmiddlename,

      CASE
        WHEN members.date_of_birth = NULL then ''
        ELSE TO_CHAR(members.date_of_birth, 'MM/DD/YYYY') 
      END as dateofbirth,

      CONCAT(date_part('year', age(members.date_of_birth))) as memberage,

      CASE
        WHEN members.mobile_number = '' then 'N/A'
        ELSE members.mobile_number    
      END AS contactnum,

      members.gender AS gender,
      members.civil_status AS civilstatus,
      centers.name AS centername,
      CONCAT(members.data->'address'->>'street',' ',
      members.data->'address'->>'district',' ',
      members.data->'address'->>'city',' ',
      members.data->'address'->>'province',' ',
      members.data->'address'->>'region',' ',
      members.data->'address'->>'old_district',' ',
      members.data->'address'->>'old_city') AS address,
      'N/A' AS businessaddress,
      'N/A' AS occupation,

      CASE
        WHEN members.place_of_birth = '' then 'N/A'
        ELSE members.place_of_birth   
      END AS placeOfBirth,

      'N/A' AS sourceofincome,
      branches.name AS branchname,
      '' AS memberaccountid,
      'approved' as appstatus,
      branches.id AS branchreferenceid,
      CONCAT(beneficiaries.first_name,' ',beneficiaries.middle_name,' ',beneficiaries.last_name) as primarybeneficiaryname,
      beneficiaries.date_of_birth as primarydateofbirth,
      beneficiaries.relationship as primaryrelationship,
      '' AS secondarybeneficiaryname,
      '' AS secondarydateofbirth,
      '' AS secondaryrelationship,
      members.data->'spouse'->>'last_name' as spouselastname,
      members.data->'spouse'->>'first_name' as spousefirstname,
      members.data->'spouse'->>'middle_name' as spousemiddlename,
      '' AS spousedateofbirth,
      '' AS spouseage,
      '' AS ids,
      members.data->>'recognition_date' AS blipdate,
      members.identification_number AS externalref,
      '' AS appchildrenadultunder
    "
    ).joins(
    "
      LEFT JOIN branches ON branches.id = members.branch_id 
      LEFT JOIN centers ON centers.id  = members.center_id
      LEFT JOIN beneficiaries ON beneficiaries.id = members.id
    "
    ).where(
      "DATE(members.data->>'recognition_date') >= ? AND DATE(members.data->>'recognition_date') <= ?",
      start_date,
      end_date
    ).find_in_batches(:batch_size => 500) do |group|

      Rails.logger.info(puts("Uploading #{group.size}"))
      member = group.map{ |o|
        {
          memberNumber: o.membernumber, 
          applicantLastName: o.applicantlastname,
          applicantFirstName: o.applicantfirstname,
          applicantMiddleName: o.applicantmiddlename,
          dateOfBirth: o.dateofbirth,
          age: o.memberage,
          contactNum: o.contactnum,
          gender: o.gender,
          civilStatus: o.civilstatus,
          center: o.centername,
          address: o.address,
          businessAddress: o.businessaddress,
          occupation: o.occupation,
          placeOfBirth: o.placeofbirth,
          sourceOfIncome: o.sourceofincome,
          branch: o.branchname,
          member_account_id: o.memberaccountid,
          branch_reference_id: o.branchreferenceid,
          primaryBeneficiaryName: o.primarybeneficiaryname,
          primarydateOfBirth: o.primarydateofbirth,
          primaryRelationship: o.primaryrelationship,
          secondaryBeneficiaryName: o.secondarybeneficiaryname,
          secondarydateOfBirth: o.secondarydateofbirth,
          secondaryRelationship: o.secondaryrelationship,
          spouseLastName: o.spouselastname,
          spouseFirstName: o.spousefirstname,
          spouseMiddleName: o.spousemiddlename,
          spouseDateOfBirth: o.spousedateofbirth,
          spouseAge: o.spouseage,
          ids: o.ids,
          appStatus: 'approved',
          blipDate: o.blipdate.to_date,
          externalRef: o.id,
          appChildrenAdultUnder: [
            {
                "dateofBirth" => "",
                "name" => "",
                "relationship" => ""
            },
            {
                "dateofBirth" => "",
                "name" => "",
                "relationship" => ""
            }
          ] 
        }
      }
      Rails.logger.info(puts(member.to_json))

      payload = member

      if is_batch.present?
       Rails.logger.info(puts "Posting to #{end_point}....")
        result = HTTParty.post(
                  end_point,
                  body: payload.to_json,
                  :headers => { 'Content-Type' => 'application/json' }
        )
        Rails.logger.info(puts(result))
      else
        payload.each do |p|
          # Posting logic here
          Rails.logger.info(puts "Posting to #{end_point}....")
          result = HTTParty.post(
                    end_point,
                    body: p.to_json,
                    :headers => { 'Content-Type' => 'application/json' }
          )
          Rail.logger.info(puts(result))
        end
      end
    end
  end

  #API for Claims
  task send_claims: :environment do
    start_date        = ENV["START_DATE"]  || Date.today - 1.month
    end_date          = ENV["END_DATE"] || Date.today
    is_batch          = ENV["BATCH"] || true 
    end_point         = ENV['KEZAR_API_SEND_CLAIMDATA'] || "https://us-central1-rms-kmba.cloudfunctions.net/api/claim/batch/upload"

    claim_type        =["BLIP", "HIIP"]

    claim = Claim.select(
      "
        claims.id,

        CASE
          WHEN claims.data->>'category_of_cause_of_death_tpd_accident' = 'Accidental Death' 
            OR claims.data->>'category_of_cause_of_death_tpd_accident' = 'Motor Vehicular' 
            OR claims.data->>'category_of_cause_of_death_tpd_accident' = 'Motor Vehicular Accident' 
          THEN 'Abiso ng Pagkamatay dahil sa Aksidente (Notice of Death due to Accident)'

          WHEN claims.data->>'category_of_cause_of_death_tpd_accident' = 'Gastro Intestinal' 
            OR claims.data->>'category_of_cause_of_death_tpd_accident' = 'Hematological'
            OR claims.data->>'category_of_cause_of_death_tpd_accident' = 'Neurogical'
            OR claims.data->>'category_of_cause_of_death_tpd_accident' = 'Cardiovascular'
            OR claims.data->>'category_of_cause_of_death_tpd_accident' = 'Neurological'
            OR claims.data->>'category_of_cause_of_death_tpd_accident' = 'Respiratory'
            OR claims.data->>'category_of_cause_of_death_tpd_accident' = 'Gynecological'
          THEN 'Abiso ng Natural na Pagkamatay (Notice of Natural Death)'
          
          WHEN claims.data->>'category_of_cause_of_death_tpd_accident' IS NULL 
            OR claims.data->>'category_of_cause_of_death_tpd_accident' = 'Suicide' 
            OR claims.data->>'category_of_cause_of_death_tpd_accident' = 'Others'
          THEN 'N/A'  
        END AS claimtype,

        TO_CHAR(claims.created_at, 'mm/dd/yyyy hh:MM PM') as datefiled,
        claims.id as reference_no,
        claims.status as claimstatus,

        CASE
          WHEN claims.data->>'classification_of_insured' = 'Legal Dependent (Spouse)' THEN 'Beneficiary'
          ELSE  'Applying as Member'
        END as claimant_type,

        CASE
          WHEN claims.data->>'account_number' IS NULL THEN '(+63) 000-000-0000'
          WHEN claims.data->>'account_number' = '' THEN '(+63) 000-000-0000'
          ELSE claims.data->>'account_number' 
        END AS claimantcontactno,

        'N/A' AS claimantemail,
        claims.data->>'beneficiary' as claimantfullname,
        
        CASE 
          WHEN claims.data->>'classification_of_insured'= 'Member' THEN 'N/A'
          ELSE claims.data->>'classification_of_insured'
        END as claimantrelationship,
        
        'N/A' as disabled_decease_address,
        
        CASE
          WHEN claims.data->>'cause_of_death_tpd_accident' IS NULL THEN 'N/A'
          WHEN claims.data->>'cause_of_death_tpd_accident' = '' THEN 'N/A'
          ELSE claims.data->>'cause_of_death_tpd_accident'
        END as disabled_decease_cause,
        
        'N/A' as disabled_decease_civilstatus,
        TO_CHAR((claims.data->>'date_of_birth')::DATE, 'mm/dd/yyyy hh:MM PM') as disabled_decease_birthdate,
        
        CASE
          WHEN claims.data->>'date_of_death_tpd_accident' IS NULL THEN 'N/A'
          ELSE TO_CHAR((claims.data->>'date_of_death_tpd_accident')::DATE, 'mm/dd/yyyy hh:MM PM')
        END as disabled_decease_date,
        
        claims.data->>'name_of_insured' as disabled_decease_fullname,
        'N/A' as disabled_decease_relationship,
        members.identification_number as member_no,
        branches.name as branch_name,
        centers.name as center_name,
        TO_CHAR((members.data->>'recognition_date')::DATE, 'mm/dd/yyyy hh:MM PM') as dateofmembership,
        CONCAT(members.first_name,' ',members.middle_name,' ',members.last_name) as memberfullname,
        claims.data->>'policy_number' as externalref, 
        '' as proofaffidavitofloss,
        '' as proofbirth,
        '' as proofclaimantid,
        '' as proofdeath,
        '' as proofincidentreport,
        '' as proofmarriage,
        '' as proofmedical,
        '' as proofmemberbirth,
        '' as proofmembership
      "
    ).joins(
      "
        LEFT JOIN members ON members.id = claims.member_id 
        LEFT JOIN branches ON branches.id = claims.branch_id
        LEFT JOIN centers ON centers.id = claims.center_id
      "
    ).where(
      " claims.claim_type IN (?)
        AND claims.created_at >= ?
        AND claims.created_at >= ?
        ",
      claim_type,
      start_date,
      end_date
    ).find_in_batches(:batch_size => 500) do |group|

      Rails.logger.info(puts("Uploading #{group.size} claimsdata..."))
      claims = group.map{|o|
        {
          claimType: o.claimtype,
          dateFiled: o.datefiled,
          referenceNo: o.reference_no,
          claimStatus: o.claimstatus,
          claimantType: o.claimant_type,
          claimantContactNo: o.claimantcontactno,
          claimantEmail: o.claimantemail,
          claimantFullName: o.claimantfullname,
          claimantRelationship: o.claimantrelationship,
          disabledDeceasedAddress: o.disabled_decease_address,
          disabledDeceasedCause: o.disabled_decease_cause,
          disabledDeceasedCivilStatus: o.disabled_decease_civilstatus,
          disabledDeceasedBirthdate: o.disabled_decease_birthdate,
          disabledDeceasedDate: o.disabled_decease_date,
          disabledDeceasedFullName: o.disabled_decease_fullname,
          disabledDeceasedRelationship: o.disabled_decease_relationship,
          memberMemberNo: o.member_no,
          memberBranch: o.branch_name,
          memberCenter: o.center_name,
          memberDateOfMembership: o.dateofmembership,
          memberFullName: o.memberfullname,
          externalRef: o.id,
          proofAffidavitOfLoss: o.proofaffidavitofloss,
          proofBirth: o.proofbirth,
          proofClaimantId: o.proofclaimantid,
          proofDeath: o.proofdeath,
          proofIncidentReport: o.proofincidentreport,
          proofMarriage: o.proofmarriage,
          proofMedical: o.proofmedical,
          proofMemberBirth: o.proofmemberbirth,
          proofMembership: o.proofmembership
        }
      }
      Rails.logger.info(puts(claims.to_json))

      payload = claims

      if is_batch.present?
        Rails.logger.info(puts "Posting to #{end_point}....")
        result = HTTParty.post(
        end_point,
          body: payload.to_json,
          :headers => { 'Content-Type' => 'application/json' }
        )
        Rails.logger.info(puts(result))
        Rails.logger.info(puts (result.code))
      else
        payload.each do |p|
          # Posting logic here
          Rails.logger.info(puts "Posting to #{end_point}....")
          result = HTTParty.post(
            end_point,
            body: p.to_json,
            :headers => { 'Content-Type' => 'application/json' }
          )
          Rails.logger.info(puts(result))
          Rails.logger.info(puts (result.code))
        end
      end
    end
  end

  # RAKE TASK TO TEST THE RECEIVING API OF KOINS
  task send_to_mba_members: :environment do
    # save new record
    branch_id         = ENV["BRANCH_ID"] || "3a74c7d5-54a5-4eec-826d-ab81f76ae31a"
    branch            = Branch.find(branch_id)
    # start_date        = ENV["START_DATE"]  || '2023-01-01'
    # end_date          = ENV["END_DATE"] || '2023-08-31'
    # member            = 'd723aa98-fdd8-4834-b531-ecd6d447dcac'

    # update record
    # branch_id         = ENV["BRANCH_ID"] || "e1562b4e-52e7-45a0-bdb5-d45675dcfc12"
    # branch            = Branch.find(branch_id)
    # start_date        = ENV["START_DATE"]  || '2022-09-09'
    # end_date          = ENV["END_DATE"] || '2022-09-10'

    is_batch          = ENV["BATCH"] || true
    # end_point         = ENV['KOINS_RECEIVING_MEMBERS'] || "http://localhost:3000/api/receive_api/save_members_api"
    end_point         = ENV['KOINS_RECEIVING_MEMBERS'] || "http://172.104.179.39/api/receive_api/save_members_api"


    member_data = Member.where(
      "members.branch_id = ?",
      branch
    ).find_in_batches(:batch_size => 100) do |group|

      Rails.logger.info(puts("Uploading #{group.size}"))
      member = group.map{ |o|
        {
          center_id: o.center_id,
          branch_id: o.branch_id,
          first_name: o.first_name,
          middle_name: o.middle_name,
          last_name: o.last_name,
          gender: o.gender,
          date_of_birth: o.date_of_birth,
          civil_status: o.civil_status,
          home_number: o.home_number,
          mobile_number: o.mobile_number,
          processed_by: o.processed_by,
          approved_by: o.approved_by,
          identification_number: o.identification_number,
          place_of_birth: o.place_of_birth,
          status: o.status,
          member_type: o.member_type,
          religion: o.religion,
          insurance_status: o.insurance_status,
          data: o.data,
          date_resigned: o.date_resigned,
          meta: o.meta,
          access_token: o.access_token,
          signature_data: o.signature_data,
          modifiable: o.modifiable,
          previous_date_resigned: o.previous_date_resigned,
          insurance_date_resigned: o.insurance_date_resigned,
          member_id: o.member_id,
          encrypted_password: o.encrypted_password,
          username: o.username,
          online_application_id: o.online_application_id,
          membership_arrangement_id: o.membership_arrangement_id,
          membership_type_id: o.membership_type_id,
          referrer_id: o.referrer_id,
          coordinator_id: o.coordinator_id,
          email: o.email,
          external_ref: o.external_ref
        }
      }

      Rails.logger.info(puts(member.to_json))

      payload = member

      if is_batch.present?
       Rails.logger.info(puts "Posting to #{end_point}....")
        result = HTTParty.post(
          end_point,
          body: payload.to_json,
          :headers => { 'Content-Type' => 'application/json' }
        )
        Rails.logger.info(puts(result))
      else
        payload.each do |p|
          # Posting logic here
          Rails.logger.info(puts "Posting to #{end_point}....")
          result = HTTParty.post(
            end_point,
            body: p.to_json,
            :headers => { 'Content-Type' => 'application/json' }
          )
          Rail.logger.info(puts(result))
        end
      end
    end
  end 

  task send_to_mba_payments: :environment do
    branch_id         = ENV["BRANCH_ID"] || "3a74c7d5-54a5-4eec-826d-ab81f76ae31a"
    branch            = Branch.find(branch_id)

    start_date                = ENV["START_DATE"]  || '2023-01-01'
    end_date                  = ENV["END_DATE"]  || '2023-08-31'
    start_recognition         = '2023-01-01'
    end_recognition           = '2023-08-31'
    is_batch                  = ENV["BATCH"] || true
    # end_point                 = ENV['KOINS_RECEIVING_PAYMENTS'] || "http://localhost:3000/api/receive_api/save_payments_api"
    end_point                 = ENV['KOINS_RECEIVING_PAYMENTS'] || "http://172.104.179.39/api/receive_api/save_payments_api"    
    account_subtypes          = ["Life Insurance Fund", "Retirement Fund"]

    payment_data = AccountTransaction.select(
      "
        account_transactions.id,
        members.identification_number,
        account_transactions.amount,
        member_accounts.account_subtype,
        account_transactions.transacted_at,
        account_transactions.status
      "
    ).joins(
      "
      LEFT JOIN member_accounts ON member_accounts.id = account_transactions.subsidiary_id
      LEFT JOIN members ON members.id = member_accounts.member_id
      "
    )
    .where(
      "account_transactions.created_at >= ? 
      AND account_transactions.created_at <= ? 
      AND member_accounts.account_subtype IN (?)
      AND DATE(members.data->>'recognition_date') >= ?
      AND DATE(members.data->>'recognition_date') <= ?",
      start_date,
      end_date,
      account_subtypes,
      start_recognition,
      end_recognition
    ).find_in_batches(:batch_size => 500) do |group|
      Rails.logger.info(puts("Uploading #{group.size}"))
      payment = group.map{ |o|
        {
          identification_number: o.identification_number,
          amount: o.amount,          
          account_subtype: o.account_subtype,
          transacted_at: o.transacted_at,
          status: o.status
        }
      }

      Rails.logger.info(puts(payment.to_json))

      payload = payment

      if is_batch.present?
       Rails.logger.info(puts "Posting to #{end_point}....")
        result = HTTParty.post(
          end_point,
          body: payload.to_json,
          :headers => { 'Content-Type' => 'application/json' },
          timeout: 120
        )
   
        Rails.logger.info(puts(result))
      else
        payload.each do |p|
          # Posting logic here
          Rails.logger.info(puts "Posting to #{end_point}....")
          result = HTTParty.post(
            end_point,
            body: p.to_json,
            :headers => { 'Content-Type' => 'application/json' },
            timeout: 120
          )
          Rail.logger.info(puts(result))
        end
      end
    end
  end

  task send_to_mba_claims: :environment do
    # branch_id         = ENV["BRANCH_ID"] || "3777729a-78e6-4e40-95f8-ef2e8a8a122e"
    # branch            = Branch.find(branch_id)

    start_date                = ENV["START_DATE"]  || '2023-03-01'
    end_date                  = ENV["END_DATE"] || '2023-03-31'
    is_batch                  = ENV["BATCH"] || true
    end_point                 = ENV['KOINS_RECEIVING_CLAIMS'] || "http://localhost:3000/api/receive_api/save_claims_api"
    claim_type                = ["BLIP", "HIIP"]
    claim_status              = "approved"

    claim_data = Claim.select(
      "
        claims.id,
        claims.date_prepared,
        claims.prepared_by,
        claims.created_at,
        claims.updated_at,
        claims.member_id,
        claims.center_id,
        claims.branch_id,
        claims.claim_type,
        claims.data,
        claims.status,
        claims.approved_by,
        claims.checked_by,
        claims.date_checked,
        claims.date_approved,
        claims.posted_by,
        claims.date_posted
      "
    ).where(
      "claims.created_at >= ? AND claims.created_at <= ? AND claims.claim_type IN (?) AND claims.status = ?",
      start_date,
      end_date,
      claim_type,
      claim_status
    ).find_in_batches(:batch_size => 1) do |group|

      Rails.logger.info(puts("Uploading #{group.size}"))
      claims = group.map{ |o|
        {
          date_prepared: o.date_prepared,
          prepared_by: o.prepared_by,
          created_at: o.created_at,
          updated_at: o.updated_at,
          member_id: o.member_id,
          center_id: o.center_id,
          branch_id: o.branch_id,
          claim_type: o.claim_type,
          data: o.data,
          status: o.status,
          approved_by: o.approved_by,
          checked_by: o.checked_by,
          date_checked: o.date_checked,
          date_approved: o.date_approved,
          posted_by: o.posted_by,
          date_posted: o.date_posted
        }
      }

      Rails.logger.info(puts(claims.to_json))
      
      payload = claims
      
      if is_batch.present?
       Rails.logger.info(puts "Posting to #{end_point}....")
        result = HTTParty.post(
          end_point,
          body: payload.to_json,
          :headers => { 'Content-Type' => 'application/json' }
        )
        Rails.logger.info(puts(result))
      else
        payload.each do |p|
          # Posting logic here
          Rails.logger.info(puts "Posting to #{end_point}....")
          result = HTTParty.post(
            end_point,
            body: p.to_json,
            :headers => { 'Content-Type' => 'application/json' }
          )
          Rail.logger.info(puts(result))
        end
      end
    end
  end
end



# ------------ Batch Upload Live Payments------------
# bundle exec rails kezar:send_payments KEZAR_API_SEND_PAYMENTS='https://us-central1-rms-kmba.cloudfunctions.net/api/payment/batch/upload' RAILS_ENV=development

# ------------ Batch Upload Live Membership------------
# bundle exec rails kezar:send_members KEZAR_API_SEND_MEMBERDATA='https://us-central1-rms-kmba.cloudfunctions.net/api/membership/batch/upload' RAILS_ENV=development

# ------------ Batch Upload Live Claims ------------
# bundle exec rails kezar:send_claims KEZAR_API_SEND_CLAIMDATA='https://us-central1-rms-kmba.cloudfunctions.net/api/claim/batch/upload' RAILS_ENV=development