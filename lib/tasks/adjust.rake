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
    members = Member.active_and_resigned

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
                                      member: member,
                                      file: File.open(ff)
                                   )

                if attachment_file.save
                  puts "Successfully uploaded file #{ff.split('/').last} for #{member.identification_number}"
                else
                  puts "Error in attaching file #{ff}"
                end
              else
                attachment.update(
                  file_name: filename,
                  member: member,
                  file: File.open(ff)
                  )
                puts "Successfully updated file #{ff.split('/').last} for #{member.identification_number}"
              end
            end
          end
        else
          puts "Member #{sub_dir_name} not found"
        end
      end
    end
  end
end
