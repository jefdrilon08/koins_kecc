module ShareCapitalSummary
	class Create
		def initialize(config: )
	 
	    @config           = config
      @branch           = Branch.find(@config[:branch])
      @as_of           	= @config[:as_of]
      @transaction_date = Date.today
      @data_store_type  = "SHARE_CAPITAL_SUMMARY"
      @member           = Member.where(status:"active", branch_id:"#{@branch.id}")
      @current_date     = Date.today()

      @data_store = DataStore.create(
        meta: {
          data_store_type: @data_store_type,
          branch_id: @branch.id,
          branch_name: @branch.name,
          as_of: @as_of,
          transaction_date: @current_date,
          date_approved: ""
        },
        data: {}
        )
		end
    def execute!
      @data = {
        records: []
      }
      @member.each do |mem|
        member_accounts = MemberAccount.where(member_id: mem.id,account_type: "EQUITY",account_subtype: "Share Capital").first
        temp = {
          id: mem.id,
          name: mem.full_name,
          center: Center.find(mem.center_id).name,
          balance: member_accounts.balance.to_f
        }
        @data[:records] << temp
      end
      @data_store.data= @data
      @data_store.status  = "done"
      @data_store.save!
      

    end
	end
end