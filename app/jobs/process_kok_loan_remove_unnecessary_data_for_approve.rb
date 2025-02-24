class ProcessKokLoanRemoveUnnecessaryDataForApprove < ApplicationJob
  queue_as :operations

  def perform(kok)
    @kok_last_data    = kok
    @id               = @kok_last_data[:id]
    @date_approved    = @kok_last_data[:date_approved]

    # raise @date_approved.inspect

    if @date_approved.present?
      kok_record = InsuranceLoanBundleEnrollment.find(@id)
      kok_data = kok_record.data
      kok_data["records"].delete_at(2)

      kok_record.update!(data: kok_data)
    end
  end
end
