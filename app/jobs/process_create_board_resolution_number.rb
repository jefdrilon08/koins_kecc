class ProcessCreateBoardResolutionNumber < ApplicationJob
    queue_as :default
  
    def perform(config)
        
        result = ::BoardResolution::Create.new(config: config).execute!
    end
  end
  