namespace :kezar do
  # FOR PAYMENTS API 
  task :send_payments => :environment do
    branch_id     = ENV["BRANCH_ID"] || "6a773bfb-db5c-4713-af70-d0ea183e68d6"
    # member_id     = ENV["MEMBER_ID"] || "3ee41573-6202-4239-81a2-f4e68ff9b912"
    branch        = Branch.find(branch_id)
    start_date    = ENV["START_DATE"] || Date.today - 2.month
    end_date      = ENV["END_DATE"] || Date.today
    endpoint      = ENV['KEZAR_API_SEND_PAYMENTS'] || "https://us-central1-rms-kmba.cloudfunctions.net/api/payment/batch/upload"
    is_batch      = ENV["BATCH"] || false

    account_type      = "INSURANCE"
    account_subtypes  = ["Life Insurance Fund", "Retirement Fund"]

    account_transactions = AccountTransaction.select(
      "members.identification_number, 
       account_transactions.transacted_at, 
       account_transactions.amount, 
       member_accounts.account_subtype, 
       account_transactions.id, 
       branches.name AS branch_name"
    ).joins(
      "INNER JOIN member_accounts ON member_accounts.id = account_transactions.subsidiary_id INNER JOIN members ON members.id = member_accounts.member_id INNER JOIN branches ON branches.id = member_accounts.branch_id"
    ).where(
      "member_accounts.account_type = ? AND member_accounts.account_subtype IN (?) AND DATE(transacted_at) >= ? AND DATE(transacted_at) <= ? AND member_accounts.branch_id = ? ",
      account_type,
      account_subtypes,
      start_date,
      end_date,
      branch.id
    ).limit(500)

    Rails.logger.info(puts "Uploading #{account_transactions.size} transactions...")
    records = account_transactions.map{ |o|
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
      Rails.logger.info(puts (result.code))
      
      
    else
      payload.each do |p|
    # Posting logic here
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

  # FOR MEMBERS API 
  task member: :environment do
    # branch_id         = Branch.find(id: )
    branch_id         = ENV["BRANCH_ID"] || "06c2fd58-e93b-4066-afd2-f3fe3a7d4f1c"
    branch            = Branch.find(branch_id)
      
    # insurance_status =["inforce", "dormant", "lapsed"]
    start_date        = ENV["START_DATE"]  || Date.today - 1.month
    end_date          = ENV["END_DATE"] || Date.today
    # member_id       = ["2f167148-b4c2-45cc-82ae-2e4924fdf64b"]
    is_batch          = ENV["BATCH"] || false
    end_point         = ENV['KEZAR_API_SEND_MEMBERDATA'] || "https://us-central1-rms-kmba.cloudfunctions.net/apiTest/membership/batch/upload"

      memberdata = Member.select(
      "members.identification_number AS membernumber,
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
        '' AS appchildrenadultunder"
    ).joins(
    "
      LEFT JOIN branches ON branches.id = members.branch_id 
      LEFT JOIN centers ON centers.id  = members.center_id
      LEFT JOIN beneficiaries ON beneficiaries.id = members.id
    "
    ).where(
      "members.branch_id = ? AND DATE(members.data->>'recognition_date') >= ? AND DATE(members.data->>'recognition_date') <= ?",
      branch,
      start_date,
      end_date
    ).limit(500)
    

    if memberdata.present?
      puts "Posting to #{end_point}...."
      member = memberdata.map{ |o|
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
          externalRef: o.externalref,
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


      puts member.to_json

      payload = member

      if is_batch.present?
       puts "Posting to #{end_point}...."
        result = HTTParty.post(
          end_point,
          body: payload.to_json,
          :headers => { 'Content-Type' => 'application/json' }
        )
        puts(result)
        puts (result.code)
      else
        payload.each do |p|
          # Posting logic here
          puts "Posting to #{end_point}...."
          result = HTTParty.post(
            end_point,
            body: payload.to_json,
            :headers => { 'Content-Type' => 'application/json' }
          )
          puts(result)
          puts (result.code)
        end
      end
    else
      puts "member not found"
    end
  end

  # FOR CLAIMS API 
  task claims: :environment do
     # branch_id         = Branch.find(id: )
    branch_id         = ENV["BRANCH_ID"] || "06c2fd58-e93b-4066-afd2-f3fe3a7d4f1c"
    branch            = Branch.find(branch_id)
      
    # insurance_status =["inforce", "dormant", "lapsed"]
    start_date        = ENV["START_DATE"]  || Date.today - 1.month
    end_date          = ENV["END_DATE"] || Date.today
    # member_id       = ["2f167148-b4c2-45cc-82ae-2e4924fdf64b"]
    is_batch          = ENV["BATCH"] || false 
    end_point         = ENV['KEZAR_API_SEND_CLAIMDATA'] || "https://us-central1-rms-kmba.cloudfunctions.net/api/claim/batch/upload"

    claim_type        =["BLIP", "HIIP"]

    claimdata = Claim.select(
      "
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
      "claims.claim_type IN (?) AND claims.branch_id = ?",
      claim_type,
      branch
    ).limit(3)

    # puts  "Uploading #{claimdata.size} claimsdata..."

    claims = claimdata.map{|o|
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
        externalRef: o.externalref,
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

    puts claims.to_json

    payload = claims

    if is_batch.present?
      puts "Posting to #{end_point}...."
      result = HTTParty.post(
      end_point,
        body: payload.to_json,
        :headers => { 'Content-Type' => 'application/json' }
      )
      puts(result)
      puts (result.code)
    else
      payload.each do |p|
        # Posting logic here
        puts "Posting to #{end_point}...."
        result = HTTParty.post(
          end_point,
          body: payload.to_json,
          :headers => { 'Content-Type' => 'application/json' }
        )
         puts(result)
        puts (result.code)
      end
    end
  end 
end

# ------------ Batch Upload Live Payments------------
# bundle exec rails kezar:send_payments BRANCH_ID='3777729a-78e6-4e40-95f8-ef2e8a8a122e' START_DATE='04-01-2022' END_DATE='12-30-2022' KEZAR_API_SEND_PAYMENTS='https://us-central1-rms-kmba.cloudfunctions.net/api/payment/batch/upload' RAILS_ENV=development

# ------------ Batch Upload Live Membership------------
# bundle exec rails kezar:member BRANCH_ID='5116c3b0-6b38-427f-9839-4cb8566151e2' START_DATE='11-01-2022' END_DATE='12-01-2022'  KEZAR_API_SEND_MEMBERDATA='https://us-central1-rms-kmba.cloudfunctions.net/api/membership/batch/upload' RAILS_ENV=development

# ------------ Batch Upload Test Membership------------
# bundle exec rails kezar:member BRANCH_ID='06c2fd58-e93b-4066-afd2-f3fe3a7d4f1c' START_DATE='11-01-2022' END_DATE='12-01-2022' KEZAR_API_SEND_MEMBERDATA='https://us-central1-rms-kmba.cloudfunctions.net/apiTest/membership/batch/upload' RAILS_ENV=development

# ------------ Batch Upload Live Claims ------------
# bundle exec rails kezar:claims BRANCH_ID='48b949af-e682-43b2-a5d2-278cff5f4972' KEZAR_API_SEND_CLAIMDATA='https://us-central1-rms-kmba.cloudfunctions.net/api/claim/batch/upload' RAILS_ENV=development

# ------------ Batch Upload Test Claims ------------
# bundle exec rails kezar:claims BRANCH_ID='48b949af-e682-43b2-a5d2-278cff5f4972' KEZAR_API_SEND_CLAIMDATA='https://us-central1-rms-kmba.cloudfunctions.net/apiTest/claim/batch/upload' RAILS_ENV=development