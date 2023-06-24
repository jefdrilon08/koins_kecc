module DataStores
  class BuildTransferAccountTransaction
    
    def initialize
      @data = {}
      @member_account =  MemberAccount.joins(:member).where(
                                                            "account_subtype = ? and 
                                                             balance = ? and 
                                                             members.branch_id = ?", 
                                                             "CBU", 
                                                             "100",
                                                             "c9616310-3076-4e8a-ba6b-722888c423d5" 
                                                            )


    end

    def execute!

      @member_account.each do |ma|
        @data[:member] << {member_account_id: ma.id , member_id: ma.member_id, balance: ma.balance  }
      end

      raise @data.inspect
      

    end


  end
end
