class ProcessKokLoan < ApplicationJob
  queue_as :default

  def perform(config)
    @config = config
    insurance_loan_bundle_enrollment         = @config[:insurance_loan_bundle_enrollment]
    four_weeks_ago                           = @config[:four_weeks_ago]
    kok_id                                   = @config[:kok_id]
    maturity_date                            = @config[:maturity_date]
    on_grace_period                          = @config[:on_grace_period]
    now                                      = @config[:now]
    age                                      = @config[:age]
    status                                   = @config[:status]
    effectivity_date                         = @config[:effectivity_date].to_date

    if age <= 75
      if status == "for-renewal"
        if now >= effectivity_date && now <= on_grace_period
          cmd = ::InsuranceLoanBundleEnrollments::UpdateGracePeriodStatus.new(
            config: config
          ).execute!
        elsif now > on_grace_period
          puts "lapsed , id: #{kok_id}"
          cmd = ::InsuranceLoanBundleEnrollments::UpdateInsuranceLoanBundleStatus.new(
            config: config
          ).execute!
        end
      end
      if status == "approved"
        if now >= four_weeks_ago && now <= maturity_date
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
