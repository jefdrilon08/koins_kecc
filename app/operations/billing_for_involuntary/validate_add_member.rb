module BillingForInvoluntary
    class ValidateAddMember < AppValidator
        def initialize(config:)
            super()
            @member = Member.find(config[:member_id])
            @data_store = DataStore.find(config[:data_store_id])
            @data = @data_store.data.with_indifferent_access
            
        end
        def execute!



            if @member.loans.active.count == 0 
                @errors[:messages] << {
                    key: "members",
                    message: "Member has no ACTIVE LOANS"
                }
            end
            
            @data[:records].each do |rec|
                if rec[:member_id] == @member.id
                    @errors[:messages] << {
                        key: "members",
                        message: "member is already added"
                    }   
                end
            end





            @errors[:messages].each do |o|
                @errors[:full_messages] << o[:message]
            end
      
            @errors
        end
    end
end