namespace :kezar do
  # FOR PAYMENTS API 
  task :send_payments => :environment do
    start_date    = ENV["START_DATE"] || Date.today - 1.month
    end_date      = ENV["END_DATE"] || Date.today
    endpoint      = ENV['KEZAR_API_SEND_PAYMENTS'] || "https://us-central1-rms-kmba.cloudfunctions.net/api/payment/batch/upload"
    is_batch      = ENV["BATCH"] || true
    
    account_type      = "INSURANCE"
    account_subtypes  = ["Life Insurance Fund", "Retirement Fund"]

    account_transactions = AccountTransaction.select(
      "account_transactions.id,
       members.identification_number, 
       account_transactions.transacted_at, 
       account_transactions.amount, 
       member_accounts.account_subtype, 
       account_transactions.id, 
       branches.name AS branch_name"
    ).joins(
      "INNER JOIN member_accounts ON member_accounts.id = account_transactions.subsidiary_id INNER JOIN members ON members.id = member_accounts.member_id INNER JOIN branches ON branches.id = member_accounts.branch_id"
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
    branch_id         = ENV["BRANCH_ID"] || "26df15a2-80de-4830-aae4-2f0645c059a3"
    branch            = Branch.find(branch_id)
    start_date        = ENV["START_DATE"]  || '2023-02-01'
    end_date          = ENV["END_DATE"] || '2023-02-28'
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
      "DATE(members.data->>'recognition_date') >= ? AND DATE(members.data->>'recognition_date') <= ? AND members.branch_id = ?",
      start_date,
      end_date,
      branch
    ).find_in_batches(:batch_size => 10) do |group|

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
    # branch_id         = ENV["BRANCH_ID"] || "3777729a-78e6-4e40-95f8-ef2e8a8a122e"
    # branch            = Branch.find(branch_id)

    start_date                = ENV["START_DATE"]  || '2023-04-03'
    end_date                  = ENV["END_DATE"] || '2023-04-05'
    is_batch                  = ENV["BATCH"] || true
    end_point                 = ENV['KOINS_RECEIVING_PAYMENTS'] || "http://localhost:3000/api/receive_api/save_payments_api"
    is_withdraw_payment       = 'false'
    is_fund_transfer          = 'false'
    is_interest               = 'false'

    payment_data = AccountTransaction.select(
      "
        account_transactions.id,
        account_transactions.subsidiary_id,
        account_transactions.subsidiary_type,
        account_transactions.amount,
        account_transactions.transaction_type,
        account_transactions.transacted_at,
        account_transactions.status,
        account_transactions.data,
        account_transactions.created_at,
        account_transactions.updated_at
      "
    ).where(
      "
        account_transactions.created_at >= ? 
        AND account_transactions.created_at <= ?
        AND account_transactions.data->>'is_withdraw_payment' = ?
        AND account_transactions.data->>'is_fund_transfer' = ?
        AND account_transactions.data->>'is_interest' = ?
      ",
      start_date,
      end_date,
      is_withdraw_payment,
      is_fund_transfer,
      is_interest
    ).find_in_batches(:batch_size => 100) do |group|

      Rails.logger.info(puts("Uploading #{group.size}"))
      payment = group.map{ |o|
        {
          subsidiary_id: o.subsidiary_id,
          subsidiary_type: o.subsidiary_type,
          amount: o.amount,
          transaction_type: o.transaction_type,
          transacted_at: o.transacted_at,
          status: o.status,
          data: o.data,
          created_at: o.created_at,
          updated_at: o.updated_at
        }
      }

      Rails.logger.info(puts(payment.to_json))

      payload = payment

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
    ).find_in_batches(:batch_size => 500) do |group|

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

