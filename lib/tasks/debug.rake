namespace :debug do
  task :load_date_completed => :environment do
    Loan.where("branch_id = ? and status = ? and date_completed IS NULL ", "3cccd843-3fa8-4693-b60c-dea2505c6b57", "paid" ).each do |l|
      account_transaction = AccountTransaction.where(subsidiary_id: l.id).order(:transacted_at).last
      Loan.find(l.id).update(date_completed: account_transaction.transacted_at)
      puts "#{l.id}"
    end
    puts "Done"
  end
  task :loan_reamortize => :environment do
    loan                    = Loan.find(ENV['ID'])
    p_principal             = ENV['P_PRINCIPAL'].to_f.round(2)
    p_monthly_interest_rate = ENV['P_MONTHLY_INTEREST_RATE'].to_f
    p_num_installments      = ENV['P_NUM_INSTALLMENTS']
    p_term                  = ENV['P_TERM']

    config  = {
      loan: loan,
      p_principal: p_principal,
      p_monthly_interest_rate: p_monthly_interest_rate,
      p_num_installments: p_num_installments,
      p_term: p_term
    }

    data  = ::Loans::Reamortize.new(
              config: config
            ).execute!

    puts "Loan:"
    puts "========================"
    puts "ID: #{data[:loan][:id]}"
    puts "Loan Product: #{data[:loan_product][:name]}"
    puts "PN Number: #{data[:loan][:pn_number]}"
    puts "Monthly Interest Rate: #{data[:loan][:monthly_interest_rate]}"
    puts "Num Installments: #{data[:loan][:num_installments]}"
    puts "Term: #{data[:loan][:term]}"
    puts "Principal: #{data[:loan][:principal]}"
    puts "Interest: #{data[:loan][:interest]}"
    puts "Principal Paid: #{data[:loan][:principal_paid]}"
    puts "Interest Paid: #{data[:loan][:interest_paid]}"
    puts "Principal Balance: #{data[:loan][:principal_balance]}"
    puts "Interest Balance: #{data[:loan][:interest_balance]}"
    puts ""

    puts "Original Amortization:"
    puts "========================"

    values  = []
    total_principal         = 0.00
    total_interest          = 0.00
    total_principal_paid    = 0.00
    total_interest_paid     = 0.00
    total_principal_balance = 0.00
    total_interest_balance  = 0.00

    data[:original_amortization_schedule_entries].each do |a|
      total_principal         += a.principal
      total_interest          += a.interest
      total_principal_paid    += a.principal_paid
      total_interest_paid     += a.interest_paid
      total_principal_balance += a.principal_balance
      total_interest_balance  += a.interest_balance

      values << [
        a.due_date.strftime("%B %d, %Y"),
        a.principal, 
        a.interest,
        a.principal_paid,
        a.interest_paid,
        a.principal_balance,
        a.interest_balance,
        a.is_paid ? 'Yes' : 'No'
      ]
    end

    values << [
      'TOTAL',
      total_principal,
      total_interest,
      total_principal_paid,
      total_interest_paid,
      total_principal_balance,
      total_interest_balance,
      ''
    ]

    original_amortization_table = TTY::Table.new(
                                    [
                                      'Due Date',
                                      'Principal',
                                      'Interest',
                                      'Principal Paid',
                                      'Interest Paid',
                                      'Principal Balance',
                                      'Interest Balance',
                                      'Is Paid'
                                    ],
                                    values
                                  )


    puts original_amortization_table.render :ascii

    puts ""

    puts "Reamortized"
    puts "========================"

    values  = []
    total_principal         = 0.00
    total_interest          = 0.00
    total_principal_paid    = 0.00
    total_interest_paid     = 0.00
    total_principal_balance = 0.00
    total_interest_balance  = 0.00

    data[:reamortized].each_with_index do |a, i|
      total_principal         += a[:principal]
      total_interest          += a[:interest]
      total_principal_paid    += a[:principal_paid]
      total_interest_paid     += a[:interest_paid]
      total_principal_balance += a[:principal_balance]
      total_interest_balance  += a[:interest_balance]

      values << [
        "Payment #{i + 1}",
        a[:principal], 
        a[:interest],
        a[:principal_paid],
        a[:interest_paid],
        a[:principal_balance],
        a[:interest_balance],
        a[:is_paid] ? 'Yes' : 'No'
      ]
    end

    values << [
      'TOTAL',
      total_principal,
      total_interest,
      total_principal_paid,
      total_interest_paid,
      total_principal_balance,
      total_interest_balance,
      ''
    ]

    reamortized_amortization_table  = TTY::Table.new(
                                        [
                                          'Due Date',
                                          'Principal',
                                          'Interest',
                                          'Principal Paid',
                                          'Interest Paid',
                                          'Principal Balance',
                                          'Interest Balance',
                                          'Is Paid'
                                        ],
                                        values
                                      )


    puts reamortized_amortization_table.render :ascii

    puts ""

    puts "Summary"
    puts "========================"
    puts "Principal: #{data[:loan][:principal]}"
    puts "Interest: #{data[:loan][:interest]}"
    puts "Remaining Principal Balance: #{data[:remaining_principal_balance]}"
    puts "Remaining Interest Balance: #{data[:remaining_interest_balance]}"
    puts "Remaining Total Balance: #{data[:remaining_balance]}"
    puts "Excess Principal Paid: #{data[:excess_principal_paid]}"
    puts "Excess Interest Paid: #{data[:excess_interest_paid]}"
    puts "Should Be Principal: #{data[:should_be_principal]}"
    puts "Should Be Interest: #{data[:should_be_interest]}"
    puts "Should Be Dues: #{data[:should_be_dues]}"

  end

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
