class ProcessApproveKpfLoanClip < ApplicationJob
  queue_as :operations

  def perform(args)
    record  = KpfLoanClip.find(args[:id])
    user    = User.find(args[:user_id])

    begin
      config  = {
        kpf_loan_clip: record,
        user: user
      }

      record  = ::KpfLoanClips::Approve.new(
                  config: config
                ).execute!

      record.update!(status: "approved")
    rescue Exception => e
      record.update!(
        status: "error",
        data: {
          exception: e,
          application_trace: Rails.backtrace_cleaner.clean(e.backtrace)
        }
      )
    end
  end
end
