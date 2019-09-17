namespace :adjust do
  task :reload_repayment_rates => :environment do
    repayment_rates = DataStore.repayment_rates

    size  = repayment_rates.size
    puts "Reloading #{size} RR data stores..."

    repayment_rates.each_with_index do |o, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Reloading #{o.id}... #{progress}%%")

      args  = {
        id: o.id,
        data_store_type: "REPAYMENT_RATES"
      }

      ProcessRepaymentRates.perform_later(args)
    end

    puts "Done."
  end

  task :generate_missing_accounts => :environment do
    members = Member.all

    if ENV['BRANCH_ID'].present?
      members = members.where(branch_id: ENV['BRANCH_ID'])
    end

    if ENV['CENTER_ID'].present?
      members = members.where(center_id: ENV['CENTER_ID'])
    end

    if ENV['MEMBER_ID'].present?
      members = members.where(id: ENV['MEMBER_ID'])
    end

    size  = members.count

    members.each_with_index do |o, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Generating missing accounts for member #{o.id}... #{progress}%%")

      ::Members::GenerateMissingAccounts.new(
        config: {
          member: o
        }
      ).execute!
    end

    puts "\nDone."
  end

  task :update_maintaining_balance => :environment do
    members = Member.active

    if ENV['BRANCH_ID'].present?
      members = members.where(branch_id: ENV['BRANCH_ID'])
    end

    if ENV['CENTER_ID'].present?
      members = members.where(center_id: ENV['CENTER_ID'])
    end

    if ENV['MEMBER_ID'].present?
      members = members.where(id: ENV['MEMBER_ID'])
    end

    size  = members.count

    members.each_with_index do |o, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Updating maintaining balance for member #{o.id}... #{progress}%%")

      ::Members::SetMaintainingBalance.new(
        config: {
          member: o
        }
      ).execute!
    end

    puts "\nDone."
  end

  task :entry_level_loan_cycle_counts => :environment do
    members = Member.active_and_resigned

    if ENV['BRANCH_ID'].present?
      members = members.where(branch_id: ENV['BRANCH_ID'])
    end

    if ENV['CENTER_ID'].present?
      members = members.where(center_id: ENV['CENTER_ID'])
    end

    if ENV['MEMBER_ID'].present?
      members = members.where(id: ENV['MEMBER_ID'])
    end

    size  = members.count

    members.each_with_index do |o, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Updating loan cycle counts for member #{o.id}... #{progress}%%")

      data  = o.data.with_indifferent_access

      # --> Loan cycle computation
      loans               = Loan.active_or_paid.where(member_id: o.id)

      if o.is_returning?
        loans = loans.where("date_approved > ?", o.previous_date_resigned)
      end

      entry_loan_products = LoanProduct.entry_point.where(id: loans.pluck(:loan_product_id).uniq)
      loans               = loans.where(loan_product_id: entry_loan_products.pluck(:id)).order("date_approved ASC")

      loan_cycles = data[:loan_cycles] || []

      # Repair loan_cycles
      entry_loan_products.each do |elp|
        found = false

        loan_cycles.each do |lc|
          if lc[:loan_product_id] == elp.id
            found = true
          end
        end

        if !found
          loan_cycles << {
            loan_product_id: elp.id,
            cycle: loans.where(loan_product_id: elp.id).order("cycle ASC").count
          }
          
          start_counter = loan_cycles.last[:cycle].to_i - loans.where(loan_product_id: elp.id).count
          loans.where(loan_product_id: elp.id).order("date_approved ASC").each do |temp_loan|
            start_counter += 1
            temp_loan.update!(cycle: start_counter)
          end
        end
      end

      data[:loan_cycles]  = loan_cycles
      o.update!(data: data)

      data        = o.data.with_indifferent_access
      loan_cycles = data[:loan_cycles] || []

      if loan_cycles.size > 0
        loan_cycles.each do |lc|
          temp_loans  = loans.where(loan_product_id: lc[:loan_product_id]).order("date_approved ASC")

          if temp_loans.size > 0
            cycle_count     = lc[:cycle].to_i
            starting_cycle  = cycle_count - temp_loans.size

            temp_loans.each do |l|
              starting_cycle = starting_cycle + 1
              l.update!(cycle: starting_cycle)
            end
          end
        end
      end

      # --> Entry point loan cycle count
      #entry_point_loan_cycle  = data[:entry_point_loan_cycle] || 0
      entry_point_loan_cycle  = 0

      entry_loan_products.each do |lp|
        max_cycle_loan  = Loan.active_or_paid.where(member_id: o.id, loan_product_id: lp.id).order("cycle ASC").last

        if max_cycle_loan.present?
          entry_point_loan_cycle += max_cycle_loan.cycle.to_i
        end
      end

      data[:entry_point_loan_cycle] = entry_point_loan_cycle

      o.update!(data: data)
    end

    puts "\nDone."
  end

  task :update_recognition_date_by_loans => :environment do
    if ENV['INSURANCE_STATUS'].present? && ENV['STATUS'].present?
      members = Member.where(insurance_status: ENV['insurance_status'], status: ENV['STATUS'])
    else
      members = Member.active_and_resigned
    end

    if ENV['BRANCH_ID'].present?
      members = members.where(branch_id: ENV['BRANCH_ID'])
    end

    size  = members.count

    members.each_with_index do |o, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Updating recognition date for insurance for member #{o.id}... #{progress}%%")

      data  = o.data.with_indifferent_access

      if data[:recognition_date].blank?
        earliest_loan = o.loans.active_or_paid.order("date_approved ASC").first

        if earliest_loan.present?
          data[:recognition_date] = earliest_loan.date_approved

          o.update!(data: data)
        end
      end
    end

    puts "\nDone."
  end

  task :update_previous_date_resigned => :environment do
    members = Member.active_and_resigned_and_pending

    if ENV['BRANCH_ID'].present?
      members = members.where(branch_id: ENV['BRANCH_ID'])
    end

    size  = members.count

    members.each_with_index do |o, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Processing previous_date_resigned updates... #{progress}%%")

      data  = o.data.with_indifferent_access

      if data[:resignation_records].present? and data[:resignation_records].last.present?
        o.update!(
          previous_date_resigned: data[:resignation_records].last[:date_resigned]
        )
      end
    end

    puts "\nDone."
  end

  task :update_loan_maturity_dates => :environment do
    loans = Loan.active_or_paid.where(maturity_date: nil)

    if ENV['BRANCH_ID'].present?
      loans = loans.where(branch_id: ENV['BRANCH_ID'])
    end

    size  = loans.count

    loans.each_with_index do |o, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Processing maturity date of loans... #{progress}%%")

      ::Loans::UpdateMaturityDate.new(
        loan: o
      ).execute!
    end

    puts "\nDone."
  end

  task :reload_new_and_resigned => :environment do
    start_date      = ENV['START_DATE'].to_date
    end_date        = ENV['END_DATE'].to_date
    branches        = Branch.all.order("name ASC")

    if ENV['BRANCH_ID'].present?
      branches  = branches.where(id: ENV['BRANCH_ID'])
    end

    data_store_type = "MONTHLY_NEW_AND_RESIGNED"

    branches.each do |branch|
      (start_date..end_date).each do |d|
        puts "Initiating monthly_new_and_resigned for branch #{branch.name} for as_of #{d}"

        record = DataStore.monthly_new_and_resigned.where(
                    "meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS date) = ?",
                    branch.id,
                    d
                  ).first

        if record.blank?
          record  = DataStore.create!(
                      meta: {
                        branch_id: branch.id,
                        branch_name: branch.name,
                        branch: {
                          id: branch.id,
                          name: branch.name
                        },
                        as_of: d,
                        data_store_type: data_store_type
                      },
                      data: {
                        status: "processing"
                      }
                    )
        else
          record.update!(
            data: {
              status: "processing"
            }
          )
        end

        args  = {
          record: record,
          data_store_type: data_store_type,
          data_store_id: record.id,
          branch_id: branch.id,
          year: d.year,
          month: d.month
        }

        ProcessMonthlyNewAndResigned.perform_later(args)
      end
    end
  end

  task :reload_member_counts => :environment do
    start_date      = ENV['START_DATE'].to_date
    end_date        = ENV['END_DATE'].to_date
    branches        = Branch.all.order("name ASC")

    if ENV['BRANCH_ID'].present?
      branches  = branches.where(id: ENV['BRANCH_ID'])
    end

    data_store_type = "MEMBER_COUNTS"

    branches.each do |branch|
      (start_date..end_date).each do |d|
        puts "Initiating member_counts for branch #{branch.name} for as_of #{d}"

        record = DataStore.member_counts.where(
                    "meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS date) = ?",
                    branch.id,
                    d
                  ).first

        if record.blank?
          record  = DataStore.create!(
                      meta: {
                        branch_id: branch.id,
                        branch_name: branch.name,
                        branch: {
                          id: branch.id,
                          name: branch.name
                        },
                        as_of: d,
                        data_store_type: data_store_type
                      },
                      data: {
                        status: "processing"
                      }
                    )
        else
          record.update!(
            data: {
              status: "processing"
            }
          )
        end

        args  = {
          record: record,
          data_store_type: data_store_type
        }

        ProcessBranchMemberCounts.perform_later(args)
      end
    end
  end

  task :perform_deposit => :environment do
    date_paid         = ENV['DATE_PAID'].to_date
    user              = User.find(ENV['USER_ID'])
    particular        = ENV['PARTICULAR']
    member            = Member.find(ENV['MEMBER_ID']) 
    amount            = ENV['AMOUNT'].to_f
    record_type       = ENV['RECORD_TYPE']
    account_subtype   = ENV['ACCOUNT_SUBTYPE']
    member_account_id = ENV['MEMBER_ACCOUNT_ID']
    enabled           = true

    config  = {
      date_paid: date_paid,
      deposit: {
        amount: amount,
        enabled: enabled,
        member_id: member_id,
        record_type: record_type,
        account_subtype: account_subtype,
        member_account_id: member_account_id
      },
      member: member,
      user: user,
      particular: particular
    }

    puts "Performing deposit for account #{member_account_id}"

    ::DepositCollections::ApproveDepositHash.new(
      config: config
    ).execute!
  end

  task :perform_deposits => :environement do
    deposit_collection    = DepositCollection.find(ENV['ID'])
    user                  = User.find(ENV['USER_ID'])
    data_deposits         = deposit_collection.deposits
    data_accounting_entry = deposit_collection.accounting_entry
    date_approved         = deposit_collection.date_approved

    data_deposits.each do |o|
      config  = {
        date_paid: date_approved,
        deposit: o,
        member: Member.find(o[:member_id]),
        user: user,
        particular: data_accounting_entry[:particular]
      }

      puts "Performing deposit for account #{o[:member_account_id]}"

      ::DepositCollections::ApproveDepositHash.new(
        config: config
      ).execute!
    end

    puts "Done."
  end

  task :perform_withdrawals => :environment do
    withdrawal_collection = WithdrawalCollection.find(ENV['ID'])
    user                  = User.find(ENV['USER_ID'])
    data_withdrawals      = withdrawal_collection.withdrawals
    data_accounting_entry = withdrawal_collection.accounting_entry
    date_approved         = withdrawal_collection.date_approved

    data_withdrawals.each do |o|
      config  = {
        date_paid: date_approved,
        withdrawal: o,
        member: Member.find(o[:member_id]),
        user: user,
        particular: data_accounting_entry[:particular]
      }

      puts "Performing withdrawal for account #{o[:member_account_id]}"

      ::WithdrawalCollections::ApproveWithdrawalHash.new(
        config: config
      ).execute!
    end

    puts "Done."
  end

  task :upload_members_recognition_date => :environment do
    file_location = ENV['MEMBERS_CSV']
    puts file_location

    CSV.foreach(file_location, headers: true) do |row|
      identification_number = row['identification_number']
      recognition_date = row['recognition_date']

      member = Member.where(identification_number: identification_number).first

      if !member.nil?
        puts "Uploading recognition date: #{recognition_date} for #{member.full_name}"   
        member_data = member.data.with_indifferent_access
        member_data[:recognition_date] = recognition_date
        member.update!(data: member_data)
      end
    end
    puts "Done!"
  end

  task :repair_validation_accounting_entry_by_id => :environment do
    puts "Repairing ..."
    member_account_validation = MemberAccountValidation.find(ENV['VALIDATION_ID'])
    data = member_account_validation.data.with_indifferent_access
    last_name = member_account_validation.prepared_by.split(", ").first
    first_name = member_account_validation.prepared_by.split(", ").last
    current_user = User.where(last_name: last_name, first_name: first_name).first
    data[:accounting_entry]  = ::MemberAccountValidations::BuildAccountingEntry.new(
                                        config: 
                                        {
                                          branch: member_account_validation.branch,
                                          member_account_validation: member_account_validation,
                                          is_remote: false,
                                          user: current_user
                                        }
                                ).execute!
    member_account_validation.data = data
    member_account_validation.save!

    puts "Done!"
  end

  task :upload_attachment_files_from_dir => :environment do
    dir_location  = ENV['DIR_LOCATION']
    puts "Searching in directory #{dir_location}"

    Dir["#{dir_location}/*"].each do |f|
      if File.directory? f
        sub_dir_name  = f.split('/').last

        member  = Member.where(identification_number: sub_dir_name).first

        if member
          puts "Found directory for member #{member.full_name}"
          Dir["#{f}/*"].each do |ff|
            if !File.directory? ff
              filename  = ff.split('/').last.split('.').first
              
              attachments = member.attachment_files  
              attachment = attachments.where(file_name: filename).first
              if attachment.nil?
                attachment_file  = AttachmentFile.new(
                                      file_name: filename,
                                      member: member
                                   )

                attachment_file.file.attach(io: File.open(ff), filename: '#{filename}.jpg', content_type: 'file/jpg')

                if attachment_file.save
                  puts "Successfully uploaded file #{ff} for #{member.identification_number}"
                else
                  puts "Error in attaching file #{ff}"
                end
              else
                attachment.file.purge
                attachment.file.attach(io: File.open(ff), filename: '#{filename}.jpg', content_type: 'file/jpg')
                attachment.update(
                  file_name: filename,
                  member: member,
                  )
                puts "Successfully updated file #{ff} for #{member.identification_number}"
              end
            end
          end
        else
          puts "Member #{sub_dir_name} not found"
        end
      end
    end
  end
  
  task :update_member_insurance_status => :environment do
    puts "Updating member insurance status"

    if ENV['BRANCH_ID'].present?
      members = Member.where(branch_id: ENV['BRANCH_ID'])
    else
      members = Member.all
    end

    if ENV['CURRENT_DATE'].present?
      current_date = ENV['CURRENT_DATE'].to_date
    else
      current_date = Date.today
    end    

    size  = members.size
    
    members.each_with_index do |member, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Validating #{member.id}... #{progress}%%")

      puts "Updating #{member.id} - #{member.full_name}"
      default_periodic_payment  = 15
      recognition_date          = member.recognition_date

      if recognition_date.present?
        member_accounts       = MemberAccount.where("account_subtype = ? AND member_id IN (?)", "Life Insurance Fund", member.id).first
        transactions          = AccountTransaction.where("amount > 0 AND subsidiary_id IN (?)", member_accounts.id).order("transacted_at ASC")

        if transactions.size > 0
          latest_payment    = member_accounts
          latest            = transactions.last
          last_payment_date = transactions.last[:transacted_at].to_date
           # Code
          current_balance          = latest_payment.balance.to_i
          num_days                 = (current_date - recognition_date).to_i
          num_weeks                = (num_days / 7).to_i + 1
          insured_amount           = num_weeks * default_periodic_payment
          amt_past_due             = (current_balance - insured_amount).to_i * -1
          num_weeks_past_due       = (amt_past_due / default_periodic_payment)
          days_lapsed              = (current_date - last_payment_date).to_i
          
          if current_balance == 0.00 && latest.data.with_indifferent_access[:is_withdraw_payment] == true
            member.update(insurance_status: "resigned")
          elsif current_balance == 0.00
            member.update(insurance_status: "dormant")
          elsif days_lapsed <= 45 && current_balance >= insured_amount
            member.update(insurance_status: "inforce")
          elsif days_lapsed > 45 && current_balance >= insured_amount
            member.update(insurance_status: "inforce")
          elsif days_lapsed <= 45 && current_balance < insured_amount && amt_past_due < 97
            member.update(insurance_status: "inforce")
          elsif days_lapsed <= 45 && current_balance < insured_amount && amt_past_due >= 97
            member.update(insurance_status: "lapsed")  
          elsif days_lapsed > 45 && current_balance < insured_amount && amt_past_due >= 97
            member.update(insurance_status: "lapsed")
          elsif days_lapsed > 45 && current_balance < insured_amount && amt_past_due < 97
            member.update(insurance_status: "inforce")  
          end
        elsif transactions.size == 0
          member.update(insurance_status: "dormant")
        end
      else
        member.update(insurance_status: "pending") 
      end

      if member.member_type == "GK"
        member.update(insurance_status: "resigned")
      elsif member.status == "resigned"
        if member.recognition_date.nil?
          member.update(insurance_status: "pending")
        else
          member.update(insurance_status: "resigned")
        end
      elsif member.status == "pending"
        member.update(insurance_status: "pending")
      elsif member.status == "archived"
        member.update(insurance_status: "dormant")
      elsif member.status == "cleared"
        member.update(insurance_status: "cleared")
      end
    end
    puts "Done!"
  end

  task :insert_child_as_legal_dependent => :environment do
    file_location = ENV['MEMBERS_CSV']
    puts file_location

    CSV.foreach(file_location, headers: true) do |row|
      identification_number = row['identification_number']
      member = Member.where(identification_number: identification_number).first
      record = LegalDependent.where(first_name: row['first_name'], middle_name: row['middle_name'], last_name: row['last_name']).first

      if record.nil?
        legal_dependent = LegalDependent.new
        legal_dependent.first_name = row['first_name']
        legal_dependent.middle_name = row['middle_name']
        legal_dependent.last_name = row['last_name']
        legal_dependent.date_of_birth = row['dob']
        # legal_dependent.relationship = 'Child'
        legal_dependent.member_id = member.id

        legal_dependent.save!
      else
        record.update!(date_of_birth: row['dob'])
      end
      puts "Updating dependents of #{identification_number}...#{member.full_name}..."
    end
  end

  task :update_member_date_of_birth => :environment do
    file_location = ENV['MEMBERS_CSV']
    puts file_location

    CSV.foreach(file_location, headers: true) do |row|
      identification_number = row['identification_number']
      member = Member.where(identification_number: identification_number).first
      dob = row['dob']
      
      puts "Updating #{identification_number}...#{member.full_name}"   
      
      if !member.nil?
        member.update!(date_of_birth: dob)
      end
    end
  end

  task :update_member_id => :environment do
    file_location = ENV['MEMBERS_CSV']
    puts file_location

    CSV.foreach(file_location, headers: true) do |row|
      identification_number = row['identification_number']
      member = Member.where(identification_number: identification_number).first
      
      puts "Updating #{identification_number}...#{member.full_name}"   
      
      if !member.nil?
        member.update!(id: row['uuid'])
      end
    end
  end

  task :load_insurance_account_transactions => :environment do
    file_location = ENV["FILE_LOCATION"]
    puts "Searching file #{file_location}"

    insurance_account_ids = []
    CSV.foreach(file_location, headers: true) do |row|
      uuid = row['uuid']
      insurance_account_transaction_record = AccountTransaction.where(id: uuid).first

      if insurance_account_transaction_record.nil?
        puts "Creating new insurance account transaction record #{uuid}..."

        insurance_account_transaction = AccountTransaction.new

        insurance_account_transaction.id = uuid
        insurance_account_transaction.transacted_at = row['transacted_at']
        insurance_account_transaction.status = row['status']
        
        # data
        insurance_account_transaction.data = {
                                              is_withdraw_payment: false,
                                              is_fund_transfer: false,
                                              is_interest: false,
                                              is_adjustment: row['is_adjustment'],
                                              is_for_exit_age: row['for_exit_age'],
                                              is_for_loan_payments: row['for_loan_payments'],
                                              accounting_entry_reference_number: row['voucher_reference_number'],
                                              accounting_entry_particular: row['particular'],
                                              beginning_balance: row['beginning_balance'],
                                              ending_balance: row['ending_balance']
                                              }
      
        statuses = ["active", "inactive"]
        insurance_account = MemberAccount.where("id = ? AND status IN (?)", row['insurance_account_uuid'], statuses).first
        
        insurance_account_transaction.subsidiary_id = insurance_account.id
        insurance_account_transaction.subsidiary_type = "MemberAccount"
        insurance_account_transaction.transaction_type = row['transaction_type']
        insurance_account_transaction.amount = row['amount']
        
        insurance_account_transaction.save!
        
        insurance_account_ids << insurance_account_transaction.subsidiary_id

        puts "Done creating!"
      else
        puts "Updating existing insurance account transaction record #{uuid}..."

        insurance_account_transaction_record_data = insurance_account_transaction_record.data.with_indifferent_access

        insurance_account_transaction_record_data[:is_withdraw_payment] = false
        insurance_account_transaction_record_data[:is_fund_transfer] = false
        insurance_account_transaction_record_data[:is_interest] = false
        insurance_account_transaction_record_data[:is_adjustment] = row['is_adjustment']
        insurance_account_transaction_record_data[:is_for_exit_age] = row['for_exit_age']
        insurance_account_transaction_record_data[:is_for_loan_payments] = row['for_loan_payments']
        insurance_account_transaction_record_data[:accounting_entry_reference_number] = row['voucher_reference_number']
        insurance_account_transaction_record_data[:accounting_entry_particular] = row['particular']
        insurance_account_transaction_record_data[:beginning_balance] = row['beginning_balance']
        insurance_account_transaction_record_data[:ending_balance] = row['ending_balance']

        insurance_account_transaction_record.update!(
          amount: row['amount'],
          subsidiary_id: row['insurance_account_uuid'],
          transaction_type: row['transaction_type'],
          transacted_at: row['transacted_at'],
          status: row['status'],
          data: insurance_account_transaction_record_data
        )

        insurance_account_ids << insurance_account_transaction_record.subsidiary_id

        puts "Done updating!"
      end
    end

    insurance_account_ids = insurance_account_ids.uniq

    MemberAccount.where(id: insurance_account_ids).each do |acc|
      ::MemberAccounts::Rehash.new(member_account: acc).execute!
    end
    puts "Done!"
  end

  task :void_validation_record => :environment do
    puts "Updating ..."
    member_account_validation_record = MemberAccountValidation.find(ENV['MEMBER_ACCOUNT_VALIDATION_ID']).member_account_validation_records.where("member_id = ? AND data ->> 'is_void' = ?", ENV['MEMBER_ID'], 'false').order("created_at ASC").last
    member_account_validation_record_data = member_account_validation_record.data.with_indifferent_access
    member_account_validation_record_data[:is_void] = true
    member_account_validation_record.update!(data: member_account_validation_record_data)
    puts "Done"
    end
  end
end
