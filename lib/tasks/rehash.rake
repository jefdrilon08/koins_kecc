namespace :rehash do
  task :loans => :environment do
    Loan.active_or_paid.each_with_index do |loan, i|
      puts "#{i}: Rehasing loan #{loan.id}..."
      ::Loans::Reage.new(
        loan: loan,
        approved_by: "SYSTEM"
      ).execute!
    end

    puts "Done."
  end
end
