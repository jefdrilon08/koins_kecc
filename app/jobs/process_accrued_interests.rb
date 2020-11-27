class ProcessAccruedInterests < ApplicationJob
  queue_as :operations

  def perform(args)
    branch: branch,
    cut_off_date: cut_off_date,
    start_date: start_date,
    end_date: end_date,
    number_of_moratorium_days:  number_of_moratorium_days
    record = ::Adjustments::AccruedInterests::CreateBatch.new(
                                                                config: config
                                                               ).execute!
  end


end
