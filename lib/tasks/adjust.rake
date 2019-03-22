namespace :adjust do
  task :entry_level_loan_cycle_counts => :environment do
    members = Member.active_and_resigned

    if ENV['BRANCH_ID'].present?
      members = members.where(branch_id: ENV['BRANCH_ID'])
    end

    if ENV['CENTER_ID'].present?
      members = members.where(center_id: ENV['CENTER_ID'])
    end

    size  = members.count

    members.each_with_index do |o, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Updating loan cycle counts for member #{o.id}... #{progress}%%")

      data  = o.data.with_indifferent_access

      # --> Loan cycle computation
      loans               = Loan.active_or_paid.where(member_id: o.id)
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

  task :reload_member_counts => :environment do
    start_date      = ENV['START_DATE'].to_date
    end_date        = ENV['END_DATE'].to_date
    branch          = Branch.find(ENV['BRANCH_ID'])
    data_store_type = "MEMBER_COUNTS"

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
end
