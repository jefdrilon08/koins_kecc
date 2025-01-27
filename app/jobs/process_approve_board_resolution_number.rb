class ProcessApproveBoardResolutionNumber < ApplicationJob
    queue_as :default
  
    def perform(config)
        result = ::BoardResolution::Approve.new(config: config).execute!

        result.update!(status: "approved")
    end
  end
  