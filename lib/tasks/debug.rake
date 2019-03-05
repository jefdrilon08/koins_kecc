namespace :debug do
  task :loan_repayment_rate => :environment do
    as_of = ENV['AS_OF'].to_date
    loan  = Loan.find(ENV['LOAN_ID'])

    data  = ::Reports::GenerateLoanRepaymentReport.new(
              config: {
                as_of: as_of,
                loan: loan
              }
            ).execute!

    puts "REPAYMENT RATE FOR LOAN #{loan.id}"
    puts "Member: #{loan.member.full_name}"
    puts "Branch: #{loan.branch.to_s}"
    puts "As of: #{as_of}"
    puts "===================================="
    puts "principal: #{data[:principal]}"
    puts "interest: #{data[:interest]}"
    puts "total: #{data[:total]}"
    puts "principal_due: #{data[:principal_due]}"
    puts "interest_due: #{data[:interest_due]}"
    puts "principal_paid: #{data[:principal_paid]}"
    puts "interest_paid: #{data[:interest_paid]}"
    puts "total_paid: #{data[:total_paid]}"
    puts "principal_paid_due: #{data[:principal_paid_due]}"
    puts "interest_paid_due: #{data[:interest_paid_due]}"
    puts "total_paid_due: #{data[:total_paid_due]}"
    puts "principal_balance: #{data[:principal_balance]}"
    puts "interest_balance: #{data[:interest_balance]}"
    puts "total_balance: #{data[:total_balance]}"
    puts "overall_principal_balance: #{data[:overall_principal_balance]}"
    puts "overall_interest_balance: #{data[:overall_interest_balance]}"
    puts "overall_balance: #{data[:overall_balance]}"
    puts "principal_rr: #{data[:principal_rr]}"
    puts "interest_rr: #{data[:interest_rr]}"
    puts "total_rr: #{data[:total_rr]}"
    puts "par: #{data[:par]}"
    puts "num_days_par: #{data[:num_days_par]}"
  end
end
