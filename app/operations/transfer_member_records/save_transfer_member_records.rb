module TransferMemberRecords
  class SaveTransferMemberRecords
    def initialize(config:)
      @particular   = default_particular
    end
    
    def execute!
     
    end
    
    def default_particular
      "to transfer member"
    end
  end
end
