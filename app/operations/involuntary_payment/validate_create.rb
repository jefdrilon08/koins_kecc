module InvoluntaryPayment
  class ValidateCreate
    def initialize(config:)
      @errors           = {messages: []}
      @config           = config
      @branch           = @config[:branch]
      @center           = @config[:center]
    end

    def execute! 
      if DataStore.where("status = 'pending' and meta ->> 'branch_id' = ? and meta ->> 'center_id' = ? and meta ->> 'data_store_type' = 'INVOLUNTARY_PAYMENT'" , @branch.id , @center.id).count > 0
        @errors[:messages] << {
          key: "billing",
          message: "Please resolve pending involuntary collections for #{@center.to_s} / #{@branch.to_s} before creating a new involuntary collection."
        }
      end
      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }
      @errors
    end

  end
end
 