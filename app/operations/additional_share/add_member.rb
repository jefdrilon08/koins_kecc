module AdditionalShare
  class AddMember
  
    def initialize(config:)
      @config           = config
      @data_store_id    = @config[:data_store_id]
      @member_id        = @config[:member_id]
      @data_store       = DataStore.find(@data_store_id)
      @data             = @data_store.data.with_indifferent_access

    end


    def execute!
      add_member!
      add_records!
      @data_store.update(data: @data)
    end


    def add_member!
      @data['record'] << {
        member_id: @member_id,
        member_account_id: MemberAccount.where(member_id: @member_id , account_subtype: "Share Capital").last.id,
        name: Member.find(@member_id).full_name,
        total_add_capital: 0.0,
        records: []
      }
    end

    def add_records!
      a = @data['record'].select{|x| x[:member_id] == @member_id}.last
      cbu = MemberAccount.where(member_id: @member_id , account_subtype: "CBU").last
      psa = MemberAccount.where(member_id: @member_id , account_subtype: "Personal Savings Account").last
      rsa = MemberAccount.where(member_id: @member_id , account_subtype: "K-IMPOK").last

      a[:records] << {
        member_account_id: cbu.id,
        accounting_code_id: "5091fee6-b2a2-40a0-a717-c53ab483ea43",
        account_subtype: "CBU",
        amount: 0.0
      }

      a[:records] << {
        member_account_id: psa.id,
        accounting_code_id: "ba2c06dc-749a-4ca3-b09c-950669385126",
        account_subtype: "Personal Savings Account",
        amount: 0.0
      } 

      a[:records] << {
        member_account_id: rsa.id,
        accounting_code_id: "b7c23e58-e44e-46ae-a3ec-b5081d6eed32",
        account_subtype: "K-IMPOK",
        amount: 0.0
      }


    end
    
  end
end
 
