namespace :adjust do
  task :offset_hours => :environment do
    start_date  = ENV['START_DATE']
    end_date    = ENV['END_DATE']
    hour        = ENV['HOUR'].to_i
    minute      = ENV['MINUTE'].to_i
    status      = ENV['STATUS'] || "approved"
    batch_size  = ENV['BATCH_SIZE'].try(:to_i) || 100
    offset      = ENV['OFFSET'].try(:to_i) || 8

    AccountTransaction.where(
      "extract(hour FROM transacted_at)::int = ? AND extract(minute FROM transacted_at) = ? AND transacted_at >= ? AND transacted_at <= ? AND amount > 0 AND status = ?", 
      hour,
      minute,
      start_date,
      end_date,
      status
    ).find_each(batch_size: batch_size) do |a|
      puts "Adjusting #{a.id}"
      a.transacted_at = (a.transacted_at + offset.hours)
      a.save(touch: false)
    end

    puts "Done."
  end

  task :load_rr_totals => :environment do
    start_date  = ENV['START_DATE'].to_date
    end_date    = ENV['END_DATE'].to_date

    data_stores = DataStore.repayment_rates.where(
                    "status = ? AND DATE(data->>'as_of') >= ? AND DATE(data->>'as_of') <= ?",
                    "done",
                    start_date,
                    end_date
                  )

    size    = data_stores.size

    puts "Found #{size} records"

    data_stores.find_each(batch_size: 1).with_index do |o, i|
      data  = o.data.with_indifferent_access
      data[:total_principal]                 = 0.00
      data[:total_principal_paid]            = 0.00
      data[:total_overall_principal_balance] = 0.00
      data[:total_interest]                  = 0.00
      data[:total_interest_paid]             = 0.00
      data[:total_overall_interest_balance]  = 0.00
      data[:total_total_paid]                = 0.00
      data[:total_principal_due]             = 0.00
      data[:total_total_due]                 = 0.00
      data[:total_principal_balance]         = 0.00
      data[:total_total_balance]             = 0.00
      data[:total_overall_balance]           = 0.00
      data[:total_rr]                        = 0
      data[:total_principal_rr]              = 0
      data[:total_principal_paid_due]        = 0.00
      data[:total_interest_paid_due]         = 0.00
      data[:total_paid_due]                  = 0.00

      # Compute totals
      data[:records].each do |r|
        data[:total_principal] += r[:principal].to_f
        data[:total_principal_paid] += r[:principal_paid].to_f
        data[:total_principal_paid_due] += r[:principal_paid_due].to_f
        data[:total_overall_principal_balance] += r[:overall_principal_balance].to_f
        data[:total_interest] += r[:interest].to_f
        data[:total_interest_paid] += r[:interest_paid].to_f
        data[:total_overall_interest_balance] += r[:overall_interest_balance].to_f
        data[:total_total_paid] += r[:total_paid].to_f
        data[:total_principal_due] += r[:principal_due].to_f
        data[:total_total_due] += r[:total_due].to_f
        data[:total_total_balance] += r[:total_balance].to_f
        data[:total_principal_balance] += r[:principal_balance].to_f
        data[:total_paid_due] += r[:total_paid_due].to_f
      end

      data[:total_overall_balance] = data[:total_overall_principal_balance] + data[:total_overall_interest_balance]
      data[:total_rr] = data[:total_paid_due] / data[:total_total_due]

      data[:total_principal_rr] = data[:total_principal_paid_due] / data[:total_principal_due]

      if data[:total_principal_rr] > 1
        data[:total_principal_rr] = 1
      end

      o.update!(data: data)

      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): #{progress}%%")
    end

    puts "\nDone."
  end

  task :convert_savings_accounts_to_equity => :environment do
    account_subtype = ENV['ACCOUNT_SUBTYPE']

    if ENV['BRANCH_ID'].present?
      branch          = Branch.find(ENV['BRANCH_ID'])
    end

    member_accounts = MemberAccount.where(account_type: "SAVINGS", account_subtype: account_subtype)

    if branch.present?
      member_accounts = member_accounts.where(branch_id: branch.id)
    end

    sets  = member_accounts.map{ |r|
              "('#{r.id}')"
            }.join(",")

    if sets.present?
      query = "
        UPDATE member_accounts AS a SET
          account_type = 'EQUITY'
        FROM (values
          #{sets}
        ) AS c(id)
        WHERE c.id = a.id::text
      "

      ActiveRecord::Base.connection.execute(query)
    end

    puts "Done."
  end

  task :insert_hiip_from_withdrawal => :environment do
    puts "Fetching withdrawal collection..."    

    withdrawal_collections = ::Insurance::FetchWithdrawalCollectionForHiip.new().execute!

    if ENV['BRANCH_ID'].present?
      withdrawal_collections = withdrawal_collections.where(branch_id: ENV['BRANCH_ID'])
    end

    if ENV['WITHDRAWAL_ID'].present?
      withdrawal_collections = withdrawal_collections.where(id: ENV['WITHDRAWAL_ID'])
    end    

    values = []

    withdrawal_collections.each do |wc|
      wc.data.with_indifferent_access[:records].each do |rec|
        puts "#{rec[:member][:id]}"
        member = Member.find(rec[:member][:id])
        puts "#{member.full_name}"
        hiip_account = MemberAccount.where(account_subtype: "Hospital Income Insurance Plan", member_id: member.id, status: "active").first
        puts "#{hiip_account.id}"

        insurance_account_id      = hiip_account.id
        transaction_type          = 'deposit'
        transacted_at             = wc[:date_approved]
        created_at                = wc[:date_approved]
        updated_at                = wc[:date_approved]
        amount                    = rec[:total_collected].to_f.round(2)
        status                    = 'approved'

        subsidiary_id     = insurance_account_id
        subsidiary_type   = 'MemberAccount'

        trans_data  = {
        is_withdraw_payment: false,
        is_fund_transfer: false,
        is_interest: false,
        is_adjustment: false,
        is_for_exit_age: false,
        is_for_loan_payments: false,
        is_time_deposit: false,
        accounting_entry_reference_number: wc.accounting_entry[:reference_number],
        beginning_balance: 0.00,
        ending_balance: 0.00,
        lock_in_period: nil,
        data: {
                date_prepared: wc[:date_approved],
                date_approved: wc[:date_approved]                                          
          }
        }

        values << "('#{subsidiary_id}', '#{subsidiary_type}', #{amount}, '#{transaction_type}', '#{transacted_at}', '#{status}', '#{created_at}', '#{updated_at}', '#{trans_data.to_json}')"
      end
    end

    if values.any?
      query = "INSERT INTO account_transactions (subsidiary_id, subsidiary_type, amount, transaction_type, transacted_at, status, created_at, updated_at, data) VALUES #{values.join(',')}"

      ActiveRecord::Base.connection.execute(query)
    end

    puts "Done!"
  end

  task :insert_insurance_from_loans => :environment do
    account_subtype     = ENV['ACCOUNT_SUBTYPE']
    accounting_code_id  = ENV['ACCOUNTING_CODE_ID']
    branch              = Branch.find(ENV['BRANCH_ID'])

    puts "Fetching journal entry amounts..."
    cmd = ::Loans::FetchJournalEntries.new(
            config: {
              branch: branch,
              accounting_code_id: accounting_code_id,
              account_subtype: account_subtype
            }
          )

    data  = cmd.execute!

    values  = []

    puts "Inserting records..."
    data[:records].select{ |o| o[:account_transaction_id].blank? }.each do |r|
      insurance_account_id      = r[:member_account_id]
      transaction_type          = 'deposit'
      transacted_at             = r[:date_approved]
      created_at                = r[:date_approved]
      updated_at                = r[:date_approved]
      amount                    = r[:amount].to_f.round(2)
      status                    = 'approved'

      subsidiary_id     = insurance_account_id
      subsidiary_type   = 'MemberAccount'

      trans_data  = {
        is_withdraw_payment: false,
        is_fund_transfer: false,
        is_interest: false,
        is_adjustment: false,
        is_for_exit_age: false,
        is_for_loan_payments: false,
        is_time_deposit: false,
        accounting_entry_reference_number: r[:reference_number],
        beginning_balance: 0.00,
        ending_balance: 0.00,
        lock_in_period: nil,
        data: r
      }

      values << "('#{subsidiary_id}', '#{subsidiary_type}', #{amount}, '#{transaction_type}', '#{transacted_at}', '#{status}', '#{created_at}', '#{updated_at}', '#{trans_data.to_json}')"
    end

    if values.any?
      query = "INSERT INTO account_transactions (subsidiary_id, subsidiary_type, amount, transaction_type, transacted_at, status, created_at, updated_at, data) VALUES #{values.join(',')}"

      ActiveRecord::Base.connection.execute(query)
    end

    # puts "Rehashing branch..."
    # ::MemberAccounts::BulkRehash.new(
    #   config: {
    #     branch: branch
    #   },
    #   account_subtype: account_subtype
    # ).execute!

    puts "Done."
  end

  task :load_withrawal_hiip_from_v1 => :environment do
    file_location = ENV["FILE_LOCATION"]
    puts "Searching file #{file_location}"

    member_account_ids = []
    CSV.foreach(file_location, headers: true) do |row|
      member = Member.find(row['member_uuid'])
      hiip_account = MemberAccount.where(account_subtype: "Hospital Income Insurance Plan", member_id: member.id, status: "active").first

      puts "Creating new insurance account transaction record #{hiip_account}..."

      account_transaction = AccountTransaction.new

      account_transaction.subsidiary_type = 'MemberAccount'
      account_transaction.subsidiary_id = hiip_account.id
      account_transaction.status = 'approved'
      account_transaction.amount = row['amount']
      account_transaction.transaction_type = 'deposit'
      account_transaction.transacted_at = row['date_approved']
      account_transaction.created_at = row['date_approved']
      account_transaction.updated_at = row['date_approved']

      # data
      account_transaction.data = {
                                              is_withdraw_payment: false,
                                              is_fund_transfer: false,
                                              is_interest: false,
                                              is_adjustment: false,
                                              is_for_exit_age: false,
                                              is_for_loan_payments: false,
                                              accounting_entry_reference_number: row['voucher_reference_number'],
                                              accounting_entry_particular: row['particular'],
                                              beginning_balance: 0.00,
                                              ending_balance: 0.00,
                                              data: {
                                                payment_collection_uuid: row['payment_collection_uuid'],
                                                or_number: row['or_number'],
                                                payment_collection_record_uuid: row['payment_collection_record_uuid'],
                                                first_date_of_payment: row['first_date_of_payment_data'],
                                                accounting_entry_uuid: row['accounting_entry_uuid'],
                                                approved_by: row['approved_by'],
                                                prepared_by: row['prepared_by'],
                                                book: row['book'],
                                                date_approved: row['date_approved'],
                                                date_prepared: row['date_prepared'],
                                                master_reference_number: row['master_reference_number']
                                                }
                                              }
  
      
      account_transaction.save!
      
      member_account_ids << account_transaction.subsidiary_id

      puts "Done creating!"  
    end

    member_account_ids = member_account_ids.uniq

    account_transactions = AccountTransaction.savings.where("amount > 0 AND subsidiary_id IN (?) AND status = ?", member_account_ids, "approved")

    MemberAccount.where(id: member_account_ids, account_type: "INSURANCE").each do |acc|
      puts "Rehashing member_account #{acc.id}..."

      ::MemberAccounts::Rehash.new(member_account: acc, account_transactions: account_transactions).execute!
    end
    
    puts "Done!"
  end

  task :update_loans_first_date_of_payment => :environment do
    query = "
      SELECT DISTINCT ON (loans.id)
        loans.id,
        amortization_schedule_entries.due_date
      FROM
        loans
      INNER JOIN
        amortization_schedule_entries
        ON amortization_schedule_entries.loan_id = loans.id
      WHERE
        loans.status IN ('active', 'paid') AND loans.first_date_of_payment IS NULL #{ENV['BRANCH_ID'].present? ? "AND loans.branch_id = #{ENV['BRANCH_ID']}" : ''}
      GROUP BY
        loans.id, amortization_schedule_entries.due_date
      ORDER BY
        loans.id, amortization_schedule_entries.due_date ASC
    "

    result  = ActiveRecord::Base.connection.execute(query).to_a

    sets  = result.map{ |r|
              "('#{r.fetch("id")}', '#{r.fetch("due_date")}')"
            }.join(",")

    if sets.present?
      query = "
        UPDATE loans AS l SET
          first_date_of_payment  = DATE(c.first_date_of_payment)
        FROM (values
          #{sets}
        ) AS c(loan_id, first_date_of_payment)
        WHERE c.loan_id = l.id::text
      "

      ActiveRecord::Base.connection.execute(query)
    end

    puts "Done."
  end

  task :update_loans_original_maturity_date => :environment do
    loans = Loan.active_or_paid

    if ENV['BRANCH_ID'].present?
      loans = loans.where(branch_id: ENV['BRANCH_ID'])
    end

    sets  = loans.map{ |o|
              cmd = ::Loans::UpdateOriginalMaturityDate.new(
                      loan: o,
                      save: false
                    )
              cmd.execute!

              original_maturity_date  = cmd.original_maturity_date

              "('#{o.id}', '#{original_maturity_date}')"
            }.join(",")

    if sets.present?
      query = "
        UPDATE loans AS l SET
          original_maturity_date  = DATE(c.original_maturity_date)
        FROM (values
          #{sets}
        ) AS c(loan_id, original_maturity_date)
        WHERE c.loan_id = l.id::text
      "

      ActiveRecord::Base.connection.execute(query)
    end

    puts "Done."
  end

  task :fill_date_released => :environment do
    loans = Loan.where(status: ['active', 'paid'], date_released: nil)

    sets  = loans.map{ |o|
              "('#{o.id}','#{o.date_approved}')"
            }.join(",")

    if sets.present?
      query = "
        UPDATE loans AS l SET
          date_released = DATE(c.date_approved)
        FROM (values
          #{sets}
        ) AS c(loan_id, date_approved)
        WHERE c.loan_id = l.id::text
      "

      ActiveRecord::Base.connection.execute(query)
    end

    puts "Done."
  end

  task :fill_date_completed_for_paid_loans => :environment do
    branch  = Branch.find(ENV['BRANCH_ID'])

    query = "
      SELECT DISTINCT ON (loans.id)
        loans.id,
        loans.pn_number,
        loans.status,
        loans.date_completed,
        account_transactions.transacted_at
      FROM
        loans
      INNER JOIN
        account_transactions
        ON account_transactions.subsidiary_id = loans.id AND status = 'approved'
      WHERE
        loans.branch_id = '#{branch.id}' AND loans.status = 'paid'
      GROUP BY
        loans.id
      ORDER BY
        account_transactions.transacted_at DESC
    "

    result  = ActiveRecord::Base.connection.execute(query).to_a
  end

  task :fill_recognition_date_from_membership_payment => :environment do
    membership_name = ENV['MEMBERSHIP_NAME'] || 'K-MBA'
    membership_type = ENV['MEMBERSHIP_TYPE'] || 'Insurance'

    query = "
      SELECT DISTINCT ON (members.id)
        members.id,
        members.first_name,
        members.middle_name,
        members.last_name,
        members.status,
        members.insurance_status,
        members.data,
        membership_payment_records.date_paid
      FROM
        members
      INNER JOIN
        membership_payment_records 
        ON membership_payment_records.member_id = members.id 
        AND membership_payment_records.membership_name = '#{membership_name}' 
        AND membership_payment_records.membership_type = '#{membership_type}'
      WHERE
        members.status IN ('active', 'resigned', 'resign')
      ORDER BY
        members.id, membership_payment_records.date_paid DESC
    "

    result  = ActiveRecord::Base.connection.execute(query).to_a
    size    = result.size

    puts "Found #{size} records"

    result.each_with_index do |r, i|
      m                       = Member.find(r.fetch("id"))
      data                    = m.data.with_indifferent_access
      data[:recognition_date] = r.fetch("date_paid")

      m.update!(data: data)

      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): #{progress}%%")
    end

    puts "\nDone."
  end

  task :asign_user_to_loans => :environment do
    branch  = Branch.find(ENV['BRANCH_ID'])

    ::Loans::AssignUser.new(
      config: {
        branch: branch
      }
    ).execute!

    puts "Done for #{branch.id}"
  end

  task :bulk_rehash => :environment do
    branch  = Branch.find(ENV['BRANCH_ID'])

    ::MemberAccounts::BulkRehash.new(
      config: {
        branch: branch
      }
    ).execute!

    puts "Done for #{branch.id}"
  end

  task :set_max_active_date => :environment do
    puts "Starting set_max_active_date..."
    current_date  = Date.today

    data  = ActiveRecord::Base.connection.execute(<<-EOS).to_a
              SELECT DISTINCT ON (loans.id)
                loans.id AS loan_id,
                loans.first_date_of_payment,
                loans.status AS status,
                DATE(account_transactions.transacted_at) as last_transaction_date,
                DATE(amortization_schedule_entries.due_date) as last_amortization_date
              FROM
                loans
                LEFT OUTER JOIN
                  account_transactions ON account_transactions.subsidiary_id = loans.id
                INNER JOIN
                  amortization_schedule_entries ON amortization_schedule_entries.loan_id = loans.id
                WHERE
                  loans.status IN ('active', 'paid', 'processing')
                ORDER BY
                  loans.id,
                  amortization_schedule_entries.due_date DESC,
                  account_transactions.transacted_at DESC
            EOS

    sets  = data.map{ |d|
              loan_id                 = d.fetch("loan_id")
              last_transaction_date   = d.try(:fetch, "last_transaction_date").try(:to_date)
              last_amortization_date  = d.try(:fetch, "last_amortization_date").try(:to_date)
              status                  = d.fetch("status")

              max_active_date = current_date

              if last_amortization_date.present?
                max_active_date = last_amortization_date
              end

              if last_transaction_date.present?
                if current_date > last_amortization_date and ['active', 'processing'].include?(status)
                  max_active_date = current_date
                elsif last_transaction_date > last_amortization_date
                  max_active_date = last_transaction_date
                elsif status == 'paid' and last_transaction_date < last_amortization_date
                  max_active_date = last_transaction_date
                end
              else
                max_active_date = current_date
              end

              "('#{loan_id}', '#{max_active_date.to_date.to_s}')"
            }.join(",")

    query = "
      UPDATE loans AS l SET
        max_active_date = DATE(c.max_active_date)
      FROM (values
        #{sets}
      ) AS c(loan_id, max_active_date)
      WHERE c.loan_id = l.id::text
    "

    ActiveRecord::Base.connection.execute(query)

    puts "Done."
  end
  
  task :repair_personal_funds => :environment do
    data_store      = DataStore.personal_funds.find(ENV["ID"])
    account_type    = ENV["ACCOUNT_TYPE"]
    account_subtype = ENV["ACCOUNT_SUBTYPE"]
    data            = data_store.data.with_indifferent_access
    as_of           = data[:as_of]
    invalid_records = 0

    size    = data[:records].size

    data[:records].each_with_index do |record, i|
      account = record[:accounts].select{ |o|
                  o[:account_type] == account_type && o[:account_subtype] == account_subtype
                }.first

      if account[:id].present?
        member_account  = MemberAccount.find(account[:id])
        result          = MemberAccounts::CheckBalance.new(config: { member_account: member_account }).execute!

        account_transactions = AccountTransaction.savings.where("amount > 0 AND subsidiary_id IN (?) AND status = ?", member_account.id, "approved")

        if result[:running_balance] != result[:ending_balance]
          puts ""
          puts "Repairing #{member_account.id}..."
          ::MemberAccounts::Rehash.new(member_account: member_account, account_transactions: account_transactions).execute!
          invalid_records += 1
        end
      end

      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): #{progress}%%")
    end

    if invalid_records.any?
      puts "Repaired #{invalid_records} invalid records out of #{size}"
    else
      puts "No invalid records found."
    end

    puts "Done!"
  end

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

      if loan_cycles.any?
        loan_cycles.each do |lc|
          temp_loans  = loans.where(loan_product_id: lc[:loan_product_id]).order("date_approved ASC")

          if temp_loans.any?
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

  task :update_member_branch_id => :environment do
    file_location = ENV['MEMBERS_CSV']
    puts file_location

    CSV.foreach(file_location, headers: true) do |row|
      identification_number = row['identification_number']
      branch_id = row['branch_id']

      member = Member.where(identification_number: identification_number).first

      if !member.nil?
        puts "Updating branch: #{member.full_name}"   
        member.update!(branch_id: branch_id)
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
          if member.active?
            puts "Found directory for member #{member.full_name}"
            Dir["#{f}/*"].each do |ff|
              if !File.directory? ff
                filename  = ff.split('/').last.split('.').first
                
                attachments = member.attachment_files  
                attachment = attachments.where(file_name: filename).first
                
                if attachment.nil?
                  if filename != "Thumbs"
                    attachment_file  = AttachmentFile.new(
                                        file_name: filename,
                                        member: member
                                     )

                    attachment_file.file.attach(io: File.open(ff), filename: '#{filename}.jpg', content_type: 'file/jpg')

                    if attachment_file.save
                      puts "Successfully uploaded file #{ff} for #{member.identification_number} #{filename}"
                    else
                      puts "Error in attaching file #{ff}"
                      puts attachment_file.errors.full_messages
                    end
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
          end
        else
          puts "Member #{sub_dir_name} not found"
        end
      end
    end
  end

  task :destroy_thumbs_attachment_file => :environment do
    puts "Destroying thumbs file ..."
    AttachmentFile.where("file_name IN (?)", ["Thumbs", "thumbs"]).each do |af|
      if af.file.present?
        puts "Destroying file of #{af.member_id}"
        af.file.purge
        af.destroy!  
      end
    end  
    puts "Done!"
  end

  task :update_insurance_status_extended_grace_period => :environment do
    current_date = Date.today
    
    if ENV['CURRENT_DATE'].present?
      current_date = ENV['CURRENT_DATE'].to_date
    end

    result  = ActiveRecord::Base.connection.execute(<<-EOS).to_a
                SELECT DISTINCT ON(member_accounts.id)
                  member_accounts.id AS member_account_id,
                  member_accounts.account_type,
                  member_accounts.account_subtype,
                  account_transactions.id AS transaction_id,
                  account_transactions.transacted_at,
                  COALESCE(account_transactions.data->>'ending_balance', '0.00')::float AS balance,
                  account_transactions.data->>'is_withdraw_payment' AS is_withdraw_payment,
                  members.data->>'recognition_date' AS recognition_date,
                  members.id AS member_id,
                  members.member_type,
                  members.status,
                  members.insurance_status,
                  members.insurance_date_resigned,
                  COUNT(account_transactions) AS acc_trans_count
                FROM
                  member_accounts
                LEFT JOIN
                  account_transactions ON account_transactions.subsidiary_id = member_accounts.id
                LEFT JOIN
                  members ON members.id = member_accounts.member_id
                WHERE
                  member_accounts.account_type = 'INSURANCE' AND member_accounts.account_subtype = 'Life Insurance Fund'
                GROUP BY
                  member_account_id,
                  transaction_id,
                  recognition_date,
                  members.id
                ORDER BY
                  member_accounts.id, account_transactions.transacted_at DESC
              EOS

    sets  = result.map{ |o|
              member_id                 = o.fetch("member_id")
              default_periodic_payment  = 15
              recognition_date          = o.fetch("recognition_date").try(:to_date)
              transactions_count        = o.fetch("acc_trans_count")

              new_status  = "dormant"
              insurance_status  = o.fetch("insurance_status")
              insurance_date_resigned  = o.fetch("insurance_date_resigned")
              status      = o.fetch("status")
              member_type = o.fetch("member_type")
              last_payment_date = o.fetch("transacted_at").try(:to_date)

              if recognition_date.present? and last_payment_date.present?
                # Code
                if transactions_count > 0 
                  current_balance         = o.fetch("balance").to_f.round(2)
                  num_days                = (current_date - recognition_date).to_i
                  num_weeks               = (num_days / 7).to_i + 1
                  insured_amount          = num_weeks * default_periodic_payment
                  amt_past_due            = (current_balance - insured_amount).to_i * -1
                  days_lapsed             = (current_date - last_payment_date).to_i

                  is_withdraw_payment = o.fetch("is_withdraw_payment")

                  if o.fetch("balance").to_f.round(2) == 0.00 && insurance_status == "resigned"  
                    new_status = "resigned"
                  elsif current_balance == 0.00 && is_withdraw_payment == "true"
                    new_status = "resigned"
                  elsif current_balance == 0.00 && !insurance_date_resigned.nil?
                    new_status = "resigned"
                  elsif days_lapsed <= 76 && current_balance >= insured_amount
                    new_status = "inforce"
                  elsif days_lapsed > 76 && current_balance >= insured_amount
                    new_status = "inforce"
                  elsif days_lapsed <= 76 && current_balance < insured_amount && amt_past_due < 163
                    new_status = "inforce"
                  elsif days_lapsed <= 76 && current_balance < insured_amount && amt_past_due >= 163
                    new_status = "lapsed"
                  elsif days_lapsed > 76 && current_balance < insured_amount && amt_past_due >= 163
                    new_status = "lapsed"
                  elsif days_lapsed > 76 && current_balance < insured_amount && amt_past_due < 163
                    new_status = "inforce"
                  end
                else
                  new_status = "dormant"
                end
              elsif recognition_date.present? and transactions_count == 0
                new_status = "dormant"
              else
                new_status = "pending"
              end

              if member_type == "GK"
                new_status = "resigned"
              elsif status == "active" && recognition_date.nil?
                new_status = "pending"
              elsif status == "pending"
                new_status = "pending"
              elsif status == "archived"
                new_status = "archived"
              elsif status == "cleared"
                new_status = "cleared"
              elsif status == "resigned" && !insurance_date_resigned.nil?
                new_status = "resigned"  
              end

              "('#{member_id}', '#{new_status}')"
            }.join(",")

    query = "
      UPDATE members AS m SET
        insurance_status = c.new_status
      FROM (values
        #{sets}
      ) AS c(member_id, new_status)
      WHERE c.member_id = m.id::text
    "

    ActiveRecord::Base.connection.execute(query)

    puts "Done."
  end

  task :update_insurance_status => :environment do
    current_date = Date.today
    
    if ENV['CURRENT_DATE'].present?
      current_date = ENV['CURRENT_DATE'].to_date
    end

    result  = ActiveRecord::Base.connection.execute(<<-EOS).to_a
                SELECT DISTINCT ON(member_accounts.id)
                  member_accounts.id AS member_account_id,
                  member_accounts.account_type,
                  member_accounts.account_subtype,
                  account_transactions.id AS transaction_id,
                  account_transactions.transacted_at,
                  COALESCE(account_transactions.data->>'ending_balance', '0.00')::float AS balance,
                  account_transactions.data->>'is_withdraw_payment' AS is_withdraw_payment,
                  members.data->>'recognition_date' AS recognition_date,
                  members.id AS member_id,
                  members.member_type,
                  members.status,
                  members.insurance_status,
                  members.insurance_date_resigned,
                  COUNT(account_transactions) AS acc_trans_count
                FROM
                  member_accounts
                LEFT JOIN
                  account_transactions ON account_transactions.subsidiary_id = member_accounts.id
                LEFT JOIN
                  members ON members.id = member_accounts.member_id
                WHERE
                  member_accounts.account_type = 'INSURANCE' AND member_accounts.account_subtype = 'Life Insurance Fund'
                GROUP BY
                  member_account_id,
                  transaction_id,
                  recognition_date,
                  members.id
                ORDER BY
                  member_accounts.id, account_transactions.transacted_at DESC
              EOS

    sets  = result.map{ |o|
              member_id                 = o.fetch("member_id")
              default_periodic_payment  = 15
              recognition_date          = o.fetch("recognition_date").try(:to_date)
              transactions_count        = o.fetch("acc_trans_count")

              new_status  = "dormant"
              insurance_status  = o.fetch("insurance_status")
              insurance_date_resigned  = o.fetch("insurance_date_resigned")
              status      = o.fetch("status")
              member_type = o.fetch("member_type")
              last_payment_date = o.fetch("transacted_at").try(:to_date)

              if recognition_date.present? and last_payment_date.present?
                # Code
                if transactions_count > 0 
                  current_balance         = o.fetch("balance").to_f.round(2)
                  num_days                = (current_date - recognition_date).to_i
                  num_weeks               = (num_days / 7).to_i + 1
                  insured_amount          = num_weeks * default_periodic_payment
                  amt_past_due            = (current_balance - insured_amount).to_i * -1
                  days_lapsed             = (current_date - last_payment_date).to_i

                  is_withdraw_payment = o.fetch("is_withdraw_payment")

                  if o.fetch("balance").to_f.round(2) == 0.00 && insurance_status == "resigned"  
                    new_status = "resigned"
                  elsif current_balance == 0.00 && is_withdraw_payment == "true"
                    new_status = "resigned"
                  elsif current_balance == 0.00 && !insurance_date_resigned.nil?
                    new_status = "resigned"
                  elsif days_lapsed <= 45 && current_balance >= insured_amount
                    new_status = "inforce"
                  elsif days_lapsed > 45 && current_balance >= insured_amount
                    new_status = "inforce"
                  elsif days_lapsed <= 45 && current_balance < insured_amount && amt_past_due < 97
                    new_status = "inforce"
                  elsif days_lapsed <= 45 && current_balance < insured_amount && amt_past_due >= 97
                    new_status = "lapsed"
                  elsif days_lapsed > 45 && current_balance < insured_amount && amt_past_due >= 97
                    new_status = "lapsed"
                  elsif days_lapsed > 45 && current_balance < insured_amount && amt_past_due < 97
                    new_status = "inforce"
                  end
                else
                  new_status = "dormant"
                end
              elsif recognition_date.present? and transactions_count == 0
                new_status = "dormant"
              else
                new_status = "pending"
              end

              if member_type == "GK"
                new_status = "resigned"
              elsif status == "active" && recognition_date.nil?
                new_status = "pending"
              elsif status == "pending"
                new_status = "pending"
              elsif status == "archived"
                new_status = "archived"
              elsif status == "cleared"
                new_status = "cleared"
              elsif status == "resigned" && !insurance_date_resigned.nil?
                new_status = "resigned"  
              end

              "('#{member_id}', '#{new_status}')"
            }.join(",")

    query = "
      UPDATE members AS m SET
        insurance_status = c.new_status
      FROM (values
        #{sets}
      ) AS c(member_id, new_status)
      WHERE c.member_id = m.id::text
    "

    ActiveRecord::Base.connection.execute(query)

    puts "Done."
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
    
    member_accounts = MemberAccount.where("account_subtype = ? AND member_id IN (?)", "Life Insurance Fund", members.pluck(:id))
    account_transactions = AccountTransaction.savings.where("amount > 0 AND subsidiary_id IN (?)", member_accounts.pluck(:id))

    members.each_with_index do |member, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Validating #{member.id}... #{progress}%%")

      puts "Updating #{member.id} - #{member.full_name}"
      default_periodic_payment  = 15
      recognition_date          = member.recognition_date

      if recognition_date.present?
        current_member_account = member_accounts.select{ |o| o.member_id == member.id }.first
        if !current_member_account.nil?
          transactions = account_transactions.select{ |o| o.subsidiary_id == current_member_account.id }

          if transactions.any?
            # latest_payment    = member_accounts
            latest            = transactions.last
            last_payment_date = transactions.last[:transacted_at].to_date
            # Code
            current_balance          = current_member_account.balance.to_i
            num_days                 = (current_date - recognition_date).to_i
            num_weeks                = (num_days / 7).to_i + 1
            insured_amount           = num_weeks * default_periodic_payment
            amt_past_due             = (current_balance - insured_amount).to_i * -1
            # num_weeks_past_due       = (amt_past_due / default_periodic_payment)
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

      t_transaction_type    = row['transaction_type']
        t_is_withdraw_payment = false
        t_is_interest         = false
        t_is_fund_transfer    = false

        if t_transaction_type == "wp"
          t_transaction_type    = "withdraw"
          t_is_withdraw_payment = true
        elsif t_transaction_type == "interest"
          t_transaction_type  = "deposit"
          t_is_interest       = true
        elsif t_transaction_type == "reverse_deposit"
          t_transaction_type  = "withdraw"
        elsif t_transaction_type == "reverse_withdraw"
          t_transaction_type  = "deposit"
        elsif t_transaction_type == "fund_transfer_deposit"
          t_transaction_type  = "deposit"
          t_is_fund_transfer  = true
        end

      if insurance_account_transaction_record.nil?
        puts "Creating new insurance account transaction record #{uuid}..."

        insurance_account_transaction = AccountTransaction.new

        insurance_account_transaction.id = uuid
        insurance_account_transaction.transacted_at = row['transacted_at']
        insurance_account_transaction.status = row['status']
        
        # data
        insurance_account_transaction.data = {
                                                is_withdraw_payment: t_is_withdraw_payment,
                                                is_fund_transfer: t_is_fund_transfer,
                                                is_interest: t_is_interest,
                                                is_adjustment: row['is_adjustment'],
                                                is_for_exit_age: row['for_exit_age'],
                                                is_for_loan_payments: row['for_loan_payments'],
                                                accounting_entry_reference_number: row['voucher_reference_number'],
                                                accounting_entry_particular: row['particular'],
                                                beginning_balance: row['beginning_balance'],
                                                ending_balance: row['ending_balance'],
                                                equity_value: row['equity_value'],
                                                data: {
                                                  id: row['id_data'],
                                                  principal: row['principal_data'],
                                                  interest: row['interest'],
                                                  first_date_of_payment: row['first_date_of_payment_data'],
                                                  maturity_date: row['maturity_date_data'],
                                                  original_maturity_date: row['original_maturity_date_data'],
                                                  accounting_entry_id: row['accounting_entry_id_data'],
                                                  journal_entry_id: row['journal_entry_id_data'],
                                                  amount: row['amount_data'],
                                                  loan_product_id: row['loan_product_id_data'],
                                                  loan_product_name: row['loan_product_name_data'],
                                                  member_id: row['member_id_data'],
                                                  date_approved: row['date_approved_data'],
                                                  date_released: row['date_released_data'],
                                                  reference_number: row['reference_number_data'],
                                                  book: row['book_data'],
                                                  member_account_id: row['member_account_id_data'],
                                                  term: row['term_data'],
                                                  num_installments: row['num_installments_data'],
                                                  account_transaction_id: row['account_transaction_id_data'],
                                                  status: row['status_data']
                                                  }
                                                }
      
        statuses = ["active", "inactive"]
        insurance_account = MemberAccount.where("id = ? AND status IN (?)", row['insurance_account_uuid'], statuses).first
        
        insurance_account_transaction.subsidiary_id = insurance_account.id
        insurance_account_transaction.subsidiary_type = "MemberAccount"
        insurance_account_transaction.transaction_type = t_transaction_type
        insurance_account_transaction.amount = row['amount']
        
        insurance_account_transaction.save!
        
        insurance_account_ids << insurance_account_transaction.subsidiary_id

        puts "Done creating!"
      else
        puts "Updating existing insurance account transaction record #{uuid}..."

        insurance_account_transaction_record_data = insurance_account_transaction_record.data.with_indifferent_access

        insurance_account_transaction_record_data[:is_withdraw_payment] = t_is_withdraw_payment
        insurance_account_transaction_record_data[:is_fund_transfer] = t_is_fund_transfer
        insurance_account_transaction_record_data[:is_interest] = t_is_interest
        insurance_account_transaction_record_data[:is_adjustment] = row['is_adjustment']
        insurance_account_transaction_record_data[:is_for_exit_age] = row['for_exit_age']
        insurance_account_transaction_record_data[:is_for_loan_payments] = row['for_loan_payments']
        insurance_account_transaction_record_data[:accounting_entry_reference_number] = row['voucher_reference_number']
        insurance_account_transaction_record_data[:accounting_entry_particular] = row['particular']
        insurance_account_transaction_record_data[:beginning_balance] = row['beginning_balance']
        insurance_account_transaction_record_data[:ending_balance] = row['ending_balance']
        insurance_account_transaction_record_data[:equity_value] = row['equity_value']
        
        if !insurance_account_transaction_record_data[:data].nil? 
          insurance_account_transaction_record_data[:data][:id] = row['id_data']
          insurance_account_transaction_record_data[:data][:principal] = row['principal_data']
          insurance_account_transaction_record_data[:data][:interest] = row['interest_data']
          insurance_account_transaction_record_data[:data][:first_date_of_payment] = row['first_date_of_payment_data']
          insurance_account_transaction_record_data[:data][:maturity_date] = row['maturity_date_data']
          insurance_account_transaction_record_data[:data][:original_maturity_date] = row['original_maturity_date_data']
          insurance_account_transaction_record_data[:data][:accounting_entry_id] = row['accounting_entry_id_data']
          insurance_account_transaction_record_data[:data][:journal_entry_id] = row['journal_entry_id_data']
          insurance_account_transaction_record_data[:data][:amount] = row['amount_data']
          insurance_account_transaction_record_data[:data][:loan_product_id] = row['loan_product_id_data']
          insurance_account_transaction_record_data[:data][:loan_product_name] = row['loan_product_name_data']
          insurance_account_transaction_record_data[:data][:member_id] = row['member_id_data']
          insurance_account_transaction_record_data[:data][:date_approved] = row['date_approved_data']
          insurance_account_transaction_record_data[:data][:date_released] = row['date_released_data']
          insurance_account_transaction_record_data[:data][:reference_number] = row['reference_number_data']
          insurance_account_transaction_record_data[:data][:book] = row['book_data']
          insurance_account_transaction_record_data[:data][:member_account_id] = row['member_account_id_data']
          insurance_account_transaction_record_data[:data][:term] = row['term_data']
          insurance_account_transaction_record_data[:data][:num_installments] = row['num_installments_data']
          insurance_account_transaction_record_data[:data][:account_transaction_id] = row['account_transaction_id_data']
          insurance_account_transaction_record_data[:data][:status] = row['status_data']
        else
          insurance_account_transaction_record_data[:data] = {
            id: row['id_data'],
            principal: row['principal_data'],
            interest: row['interest_data'],
            first_date_of_payment: row['first_date_of_payment_data'],
            maturity_date: row['maturity_date_data'],
            original_maturity_date: row['original_maturity_date_data'],
            accounting_entry_id: row['accounting_entry_id_data'],
            journal_entry_id: row['journal_entry_id_data'],
            amount: row['amount_data'],
            loan_product_id: row['loan_product_id_data'],
            loan_product_name: row['loan_product_name_data'],
            member_id: row['member_id_data'],
            date_approved: row['date_approved_data'],
            date_released: row['date_released_data'],
            reference_number: row['reference_number_data'],
            book: row['book_data'],
            member_account_id: row['member_account_id_data'],
            term: row['term_data'],
            num_installments: row['num_installments_data'],
            account_transaction_id: row['account_transaction_id_data'],
            status: row['status_data']
          }
        end

        insurance_account_transaction_record.update!(
          amount: row['amount'],
          subsidiary_id: row['insurance_account_uuid'],
          transaction_type: t_transaction_type,
          transacted_at: row['transacted_at'],
          status: row['status'],
          data: insurance_account_transaction_record_data
        )

        insurance_account_ids << insurance_account_transaction_record.subsidiary_id

        puts "Done updating!"
      end
    end

    insurance_account_ids = insurance_account_ids.uniq

    # account_transactions = AccountTransaction.savings.where("amount > 0 AND subsidiary_id IN (?) AND status = ?", insurance_account_ids, "approved")

    # MemberAccount.where(id: insurance_account_ids, account_type: "INSURANCE").each do |acc|
    #   puts "Rehashing member_account #{acc.id}..."

    #   ::MemberAccounts::Rehash.new(member_account: acc, account_transactions: account_transactions).execute!
    # end

    # this
    insurance_account_id = insurance_account_ids.first
    branch = MemberAccount.where(id: insurance_account_id).first.member.branch

    # Rehash accounts
    puts "Rehashing ..."
    ::MemberAccounts::BulkRehash.new(
      config: {
        branch: branch
      }
    ).execute!
    # this

    puts "Done!"
  end

  task :void_validation_record_by_ids => :environment do
    puts "Updating ..."
    member_account_validation_record = MemberAccountValidation.find(ENV['MEMBER_ACCOUNT_VALIDATION_ID']).member_account_validation_records.where("member_id = ? AND data ->> 'is_void' = ?", ENV['MEMBER_ID'], 'false').order("created_at ASC").last
    member_account_validation_record_data = member_account_validation_record.data.with_indifferent_access
    member_account_validation_record_data[:is_void] = true
    member_account_validation_record.update!(data: member_account_validation_record_data)
    puts "Done"
  end

  task :void_validation_record_of_balik_kasapi => :environment do
    puts "Updating ..."
    Member.active.each do |member|
      if member.data.with_indifferent_access[:restoration_records].present?
        member_account_validation_record = MemberAccountValidationRecord.where("member_id = ? AND data ->> 'is_void' = ?", member.id, 'false').order("created_at ASC").last
        if !member_account_validation_record.nil?
          puts "Voiding member account validation record of #{member.full_name}"
          member_account_validation_record_data = member_account_validation_record.data.with_indifferent_access
          member_account_validation_record_data[:is_void] = true
          member_account_validation_record.update!(data: member_account_validation_record_data)
        end
      end
    end
    puts "Done"
  end

  task :update_center_name => :environment do
    file_location = ENV['CENTERS_CSV']
    puts file_location

    CSV.foreach(file_location, headers: true) do |row|
      center = Center.find(row['center_id'])

      if !center.nil?
        puts "Updating: #{center.name}"  
        center.update!(name: row['center_name'])
      end
    end
    puts "Done!"
  end

  task :update_identification_number_by_uuid => :environment do
    file_location = ENV['MEMBERS_CSV']
    puts file_location

    CSV.foreach(file_location, headers: true) do |row|
      member = Member.find(row['uuid'])

      if !member.nil?
        puts "Updating: #{member.full_name}"  
        member.update!(identification_number: row['identification_number'])
      end
    end
    puts "Done!"
  end

  task :repair_members_member_accounts => :environment do
    puts "Repairing ..."

    members = Member.all

    members.each do |member|
      puts "Updating: #{member.full_name}"
      center = member.center
      branch = member.branch

      MemberAccount.where(member_id: member.id).each do |a|
        a.update!(center: center, branch: branch)
      end
    end
    puts "Done!"
  end

  task :update_insurance_date_resigned_using_file => :environment do
    file_location = ENV['MEMBERS_CSV']
    puts file_location

    CSV.foreach(file_location, headers: true) do |row|
      member = Member.find(row['uuid'])

      if !member.nil?
        if member.resigned?
          puts "Updating: #{member.full_name}"  
          member.update!(insurance_date_resigned: row['insurance_date_resigned'].to_date)
        end
      end
    end
    puts "Done!"
  end

  task :update_insurance_date_resigned => :environment do
    members = Member.where(insurance_status: "resigned")

    size  = members.count

    members.each_with_index do |o, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Updating insurance date resigned of member #{o.full_name}... #{progress}%%")

      data  = o.data.with_indifferent_access
      
      if data[:insurance_resignation].present?
        data_insurance_date_resigned = data[:insurance_resignation][:date_resigned]
        o.update!(insurance_date_resigned: data_insurance_date_resigned)
      else
        insurance_date_resigned = o.date_resigned  
        o.update!(insurance_date_resigned: insurance_date_resigned)
      end
    end

    puts "\nDone."
  end

  task :update_accounting_entry => :environment do
    member_account_validation = MemberAccountValidation.approved.all
    current_user = User.first
    member_account_validation.where(data: nil).each do |o|
      data = { accounting_entry: ::MemberAccountValidations::BuildAccountingEntryForImport.new(
                config: 
                {
                  user: current_user, 
                  member_account_validation: o, 
                  is_remote: o.is_remote,
                  branch: o.branch,
                  status: o.status,
                  reference_number: o.reference_number, 
                  approved_by: o.approved_by
                }
              ).execute! 
            }
      o.update!(data: data)
    end
  end

  task :process_insurance_member_counts => :environment do
    @data_store_type  = "INSURANCE_MEMBER_COUNTS"
    @as_of            = Date.today

    if ENV['CURRENT_DATE'].present?
      @as_of = ENV['CURRENT_DATE'].to_date
    end

    @branches         = Branch.all

    @branches.each do |branch|

      puts "Processing #{branch.name}"

      @record = DataStore.insurance_member_counts.where(
                  "meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS date) = ?",
                  branch.id,
                  @as_of
                ).first

      if @record.blank?
        @record = DataStore.create!(
                    meta: {
                      branch_id: branch.id,
                      branch_name: branch.name,
                      branch: {
                        id: branch.id,
                        name: branch.name
                      },
                      as_of: @as_of,
                      data_store_type: @data_store_type
                    },
                    data: {
                      status: "processing"
                    }
                  )

        args  = {
          record: @record,
          data_store_type: @data_store_type
        }

        ProcessInsuranceBranchMemberCounts.perform_later(args)
      end

      puts "Done!"
    end
  end

  task :process_personal_funds => :environment do
    @data_store_type  = "PERSONAL_FUNDS"
    @as_of            = Date.today
    @branches         = Branch.all

    if ENV['CURRENT_DATE'].present?
      @as_of = ENV['CURRENT_DATE'].to_date
    end

    @branches.each do |branch|

      puts "Processing #{branch.name}"

      @record = DataStore.personal_funds.where(
                "meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS date) = ?",
                branch.id,
                @as_of
              ).first

      if @record.blank?
        @record = DataStore.create!(
                  meta: {
                    branch_id: branch.id,
                    branch_name: branch.name,
                    as_of: @as_of,
                    data_store_type: @data_store_type,
                    progress: 0
                  },
                  data: {
                    status: "processing"
                  }
                )

        args  = {
          id: @record.id,
          data_store_type: @data_store_type
        }

        ProcessPersonalFunds.perform_later(args)
      end
      puts "Done!"
    end
  end

  task :process_claims_counts => :environment do
    @data_store_type  = "CLAIMS_COUNTS"
    @as_of            = Date.today
    @branches         = Branch.all

    if ENV['CURRENT_DATE'].present?
      @as_of = ENV['CURRENT_DATE'].to_date
    end

    @branches.each do |branch|

      puts "Processing #{branch.name}"

      @record = DataStore.claims_counts.where(
                      "meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS date) = ?",
                      branch.id,
                      @as_of
                    ).first

      if @record.blank?
        @record = DataStore.create!(
                    meta: {
                      branch_id: branch.id,
                      branch_name: branch.name,
                      branch: {
                        id: branch.id,
                        name: branch.name
                      },
                      as_of: @as_of,
                      data_store_type: @data_store_type
                    },
                    data: {
                      status: "processing"
                    }
                  )

        args  = {
          record: @record,
          data_store_type: @data_store_type
        }

        ProcessClaimsCounts.perform_later(args)
      end
      puts "Done!"
    end
  end

  task :insert_equity_value_to_life_transactions => :environment do
    puts "Inserting ..."
    
    if ENV['BRANCH_ID'].present?
      @branches = Branch.where(id: ENV['BRANCH_ID'])
    else
      @branches = Branch.all  
    end

    member_account_ids = MemberAccount.where("account_type = ? AND account_subtype = ? AND status = ? AND branch_id IN (?)", "INSURANCE", "Life Insurance Fund", "active", @branches.ids).ids.uniq
    account_transactions = AccountTransaction.savings.where("amount > 0 AND subsidiary_id IN (?) AND status = ?", member_account_ids, "approved").order("updated_at DESC")

    size = account_transactions.count

    account_transactions.each_with_index do |at, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Insreting for transaction #{at.id}... #{progress}%%")  

      at_data = at.data.with_indifferent_access
      ev_amount = at_data[:ending_balance].to_f / 2
      at_data[:equity_value] = ev_amount
      at.update!(data: at_data)
    end

    puts "\nDone!"
  end

  task :insert_equity_value_to_life_account => :environment do
    puts "Inserting ..."

    if ENV['BRANCH_ID'].present?
      @branches = Branch.where(id: ENV['BRANCH_ID'])
    else
      @branches = Branch.all  
    end

    member_accounts = MemberAccount.where("account_type = ? AND account_subtype = ? AND status = ? AND branch_id IN (?)", "INSURANCE", "Life Insurance Fund", "active", @branches.ids)
    transactions = AccountTransaction.savings.where("subsidiary_id IN (?) AND status = ?", member_accounts.ids, "approved")

    size = member_accounts.count

    member_accounts.each_with_index do |ma, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Insreting for member account #{ma.id}... #{progress}%%")

      last_transaction = transactions.where("subsidiary_id = ?", ma.id).order("transacted_at ASC").last   
        
      if !last_transaction.nil?  
        latest_ev_amount = last_transaction.data.with_indifferent_access[:equity_value] 
        if !ma.member_id.nil?
          if ma.data.nil?
            ma.data = { equity_value: latest_ev_amount }
            ma.save!
          else
            ma_data = ma.data.with_indifferent_access
            ma_data[:equity_value] = latest_ev_amount
            ma.update!(data: ma_data)
          end
        end
      end
    end 

    puts "\nDone!"
  end

  task :insert_equity_value_to_life_account_from_balance => :environment do
    puts "Inserting ..."

    if ENV['BRANCH_ID'].present?
      @branches = Branch.where(id: ENV['BRANCH_ID'])
    else
      @branches = Branch.all  
    end

    member_accounts = MemberAccount.where("account_type = ? AND account_subtype = ? AND status = ? AND branch_id IN (?)", "INSURANCE", "Life Insurance Fund", "active", @branches.ids)

    size = member_accounts.count

    member_accounts.each_with_index do |ma, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Insreting for member account #{ma.id}... #{progress}%%")
    
      balance = ma.balance.to_f

      if balance > 0
        if !ma.member_id.nil?
          if ma.data.nil?
            ma.data = { equity_value: balance / 2 }
            ma.save!
          else
            ma_data = ma.data.with_indifferent_access
            ma_data[:equity_value] = balance / 2
            ma.update!(data: ma_data)
          end
        end
      end
    end 

    puts "\nDone!"
  end

  task :insert_equity_value_to_life_last_transaction => :environment do
    puts "Inserting ..."

    if ENV['BRANCH_ID'].present?
      @branches = Branch.where(id: ENV['BRANCH_ID'])
    else
      @branches = Branch.all  
    end

    member_accounts = MemberAccount.where("account_type = ? AND account_subtype = ? AND status = ? AND branch_id IN (?)", "INSURANCE", "Life Insurance Fund", "active", @branches.ids)

    size = member_accounts.count

    member_accounts.each_with_index do |ma, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Insreting for member account #{ma.id}... #{progress}%%")

      last_transaction = AccountTransaction.savings.where("subsidiary_id IN (?) AND status = ?", ma.id, "approved").order("transacted_at ASC").last   
        
      if !last_transaction.nil?  
        at_data = last_transaction.data.with_indifferent_access
        ev_amount = at_data[:ending_balance].to_f / 2
        at_data[:equity_value] = ev_amount
        last_transaction.update!(data: at_data)
      end
    end 

    puts "\nDone!"
  end

  task :update_ev_and_policy_loan_value_for_validation_record => :environment do
    puts "Updating ..."
    member_account_validations = MemberAccountValidation.all

    if ENV['BRANCH_ID'].present?
      member_account_validations = member_account_validations.where(branch_id: ENV['BRANCH_ID'])
    end

    member_account_validations.each do |member_account_validation|
      member_account_validation.member_account_validation_records.each do |member_account_validation_record|
        
        if member_account_validation_record.policy_loan.nil?
          member_account_validation_record.update!(policy_loan: 0.00)
        end

        if member_account_validation_record.equity_value.nil?
          member_account_validation_record.update!(equity_value: 0.00)
        end        
      end
    end
      
    puts "Done"
  end

  task :repair_claims_accounting_entry => :environment do
    puts "Repairing ..."
    branch = Branch.where(id: Settings.try(:defaults).try(:default_branch).try(:id)).first
    claim = Claim.find(ENV['CLAIM_ID'])

    first_name = claim.prepared_by.split(" ").first
    last_name = claim.prepared_by.split(" ").last

    user = User.where(first_name: first_name, last_name: last_name).first

    if user.nil?
      user = User.find("42ae07d6-521f-4ea8-9d2e-7f48ab716116")
    end

    claim_data = claim.data.with_indifferent_access
        
    claim_data[:accounting_entry] = {}
    claim_data[:accounting_entry]  = ::Claims::BuildAccountingEntry.new(
                                config: {
                                  branch: branch,
                                  claim: claim,
                                  user: user
                                }
                              ).execute!

    claim.update!(data: claim_data)
      
    puts "Done"
  end

  task :insert_equity_value_interest => :environment do
    puts "Inserting ..."

    @start_date = nil
    @end_date = nil

    if ENV['START_DATE'].present? 
      @start_date = ENV['START_DATE'].to_date
    end

    if ENV['END_DATE'].present? 
      @end_date = ENV['END_DATE'].to_date
    end

    if ENV['BRANCH_ID'].present?
      @branches = Branch.where(id: ENV['BRANCH_ID'])
    else
      @branches = Branch.all  
    end

    member_accounts = MemberAccount.where("account_type = ? AND account_subtype = ? AND status = ? AND branch_id IN (?)", "INSURANCE", "Life Insurance Fund", "active", @branches.ids)

    size = member_accounts.count

    member_accounts.each_with_index do |member_account, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Insreting for member account #{member_account.id}... #{progress}%%")

      ::MemberAccounts::ComputeEquityValueInterest.new(member_account: member_account, start_date: @start_date, end_date: @end_date).execute!
    end 

    puts "\nDone!"
  end
end
