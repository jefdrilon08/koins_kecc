class ProcessUpdateInsuranceStatusPerBranch < ApplicationJob
  queue_as :default

  def perform(update_insurance_status_per_branch, branch_id)
    command = "bundle exec rake #{update_insurance_status_per_branch} BRANCH_ID=#{branch_id}"
    system(command)
  end
end
