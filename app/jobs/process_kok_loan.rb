class ProcessKokLoan < ApplicationJob
  queue_as :default

  def perform(config)
    @config = config
    insurance_loan_bundle_enrollment         = @config[:insurance_loan_bundle_enrollment]
    five_weeks_ago                           = @config[:five_weeks_ago]
    kok_id                                   = @config[:kok_id]
    maturity_date                            = @config[:maturity_date]
    now                                      = @config[:now]
    age                                      = @config[:age]
    status                                   = @config[:status]
    effectivity_date                         = @config[:effectivity_date].to_date

    # raise effectivity_date.inspect
    if age <= 75
      if status == "for-renewal"
        if now >= five_weeks_ago && now <= effectivity_date
          puts "for-renewal, maturity date #{effectivity_date}, id: #{kok_id}"
          cmd = ::InsuranceLoanBundleEnrollments::MemberRenewal.new(
            config: config
          ).execute!
        elsif now > effectivity_date
          puts "lapsed , id: #{kok_id}"
          cmd = ::InsuranceLoanBundleEnrollments::UpdateInsuranceLoanBundleStatus.new(
            config: config
          ).execute!
        end
      elsif status == "appproved"
        if now >= five_weeks_ago && now <= maturity_date
          puts "for-renewal, maturity date #{maturity_date}, id: #{kok_id}"
          cmd = ::InsuranceLoanBundleEnrollments::MemberRenewal.new(
            config: config
          ).execute!
        elsif now > maturity_date
          puts "lapsed , id: #{kok_id}"
          cmd = ::InsuranceLoanBundleEnrollments::UpdateInsuranceLoanBundleStatus.new(
            config: config
          ).execute!
        end
      end
    else
      raise "Your age is not qualified for Renewal. Member ID : #{insurance_loan_bundle_enrollment.id}".inspect
    end
  end
end
