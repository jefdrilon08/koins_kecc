namespace :load do
  task :loan_cycles_from_file => :environment do
    puts "reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    data        = JSON.parse(File.read("#{params[:root]}/#{params[:filename]}")).deep_symbolize_keys!
    loan_cycles = data[:loan_cycles]

    size  = loan_cycles.size

    loan_cycles.each_with_index do |o, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Processing loan_cycles... #{progress}%%")
      loan  = Loan.where(id: o[:id]).first

      if loan.present?
        loan.update!(cycle: o[:cycle])
      else
        puts ""
        puts "Loan #{o[:id]} not found"
      end
    end

    puts "Done."
  end

  task :member_loan_cycles_from_file => :environment do
    puts "reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    data  = JSON.parse(File.read("#{params[:root]}/#{params[:filename]}")).deep_symbolize_keys!

    member_loan_cycles  = data[:member_loan_cycles]

    size  = member_loan_cycles.size

    member_loan_cycles.each_with_index do |o, i|
      progress  = (((i + 1).to_f / size.to_f) * 100).round(2)
      printf("\r(#{i+1}/#{size}): Processing member_loan_cycles... #{progress}%%")
      member    = Member.where(id: o[:member_id]).first

      if member.present?
        member_data = member.data.with_indifferent_access

        loan_cycles = member_data[:loan_cycles]

        if loan_cycles.blank?
          loan_cycles = []
        end

        update  = false
        loan_cycles.each_with_index do |lc, i|
          if lc[:loan_product_id] == o[:loan_product_id]
            loan_cycles[i][:cycle] = o[:cycle]
            update  = true
          end
        end

        if !update
          loan_cycles << o
        end

        member_data[:loan_cycles] = loan_cycles

        member.update!(data: member_data)
      else
        puts ""
        puts "Member #{o[:member_id]} not found"
      end
    end

    puts "Done."
  end

  task :member_shares_from_file => :environment do
    puts "reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertMemberSharesFromFile.new(params: params).execute!

    puts "Done."
  end

  task :beneficiaries_from_file => :environment do
    puts "reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertBeneficiariesFromFile.new(params: params).execute!

    puts "Done."
  end

  task :legal_dependents_from_file => :environment do
    puts "reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertLegalDependentsFromFile.new(params: params).execute!

    puts "Done."
  end

  task :billings_from_file => :environment do
    puts "reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertAccountTransactionCollectionsFromFile.new(params: params).execute!

    puts "Done."
  end

  task :loan_payments_from_file => :environment do
    puts "reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertLoanPaymentsFromFile.new(params: params).execute!

    puts "Done."
  end

  task :member_account_transactions_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertMemberAccountTransactionsFromFile.new(params: params).execute!

    puts "Done."
  end

  task :member_accounts_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertMemberAccountsFromFile.new(params: params).execute!

    puts "Done."
  end

  task :amortization_schedule_entries_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertAmortizationScheduleEntriesFromFile.new(params: params).execute!

    puts "Done."
  end

  task :loans_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertLoansFromFile.new(params: params).execute!

    puts "Done."
  end

  task :update_loan_products_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::UpdateLoanProductsFromFile.new(params: params).execute!

    puts "Done."
  end

  task :loan_products_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertLoanProductsFromFile.new(params: params).execute!

    puts "Done."
  end

  task :project_types_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertProjectTypesFromFile.new(params: params).execute!

    puts "Done."
  end

  task :project_type_categories_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertProjectTypeCategoriesFromFile.new(params: params).execute!

    puts "Done."
  end

  task :journal_entries_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertJournalEntriesFromFile.new(params: params).execute!

    puts "Done."
  end

  task :accounting_entries_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertAccountingEntriesFromFile.new(params: params).execute!

    puts "Done."
  end

  task :members_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertMembersFromFile.new(params: params).execute!

    puts "Done."
  end

  task :centers_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertCentersFromFile.new(params: params).execute!

    puts "Done."
  end

  task :branches_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertBranchesFromFile.new(params: params).execute!

    puts "Done."
  end

  task :clusters_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertClustersFromFile.new(params: params).execute!

    puts "Done."
  end

  task :areas_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertAreasFromFile.new(params: params).execute!

    puts "Done."
  end

  task :accounting_codes_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertAccountingCodesFromFile.new(params: params).execute!

    puts "Done."
  end

  task :users_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertUsersFromFile.new(params: params).execute!

    puts "Done."
  end

  task :accounting_funds_from_file => :environment do
    puts "Reading file #{ENV['FILENAME']} from #{ENV['ROOT']}..."

    params  = {
      root: ENV['ROOT'],
      filename: ENV['FILENAME']
    }

    ::Loaders::InsertAccountingFundsFromFile.new(params: params).execute!

    puts "Done."
  end
end
