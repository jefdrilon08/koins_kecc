class ProcessMemberLoanMoratorium < ApplicationJob
  queue_as :default

  def perform(args)
    member_loan_moratorium  = MemberLoanMoratorium.find(args[:id])
    user                    = User.find(args[:user_id])

    begin
    rescue Exception => e
      logger.info("Exception occurred for member_loan_moratorium #{args[:id]}")
      logger.info e

      member_loan_moratorium.update!(
        status: "pending"
      )
    end
  end
end
