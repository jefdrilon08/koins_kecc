module Print
  class PrintSavingsLedger
    def initialize(member_account:)
      @member_account = member_account
      @data           = {}
    end

    def execute! 
        @member = Member.find(@member_account.member_id)
        @center = Center.find(@member.center_id)
        @branch = Branch.find(@member.branch_id) 
        @account_transaction = []
        @account_transaction = AccountTransaction.where(subsidiary_id: @member_account.id,status: "approved").order('transacted_at ASC')
        #raise @data.inspect  
        @data[:account_type] =@member_account.account_subtype 
        @data[:first_name]= @member.first_name
        @data[:last_name]= @member.last_name
        @data[:middle_name]= @member.middle_name
        @data[:branch]    = @branch.name
        @data[:center] = @center.name
        @data[:company_name] = Settings.company_namme
        @data[:company_address]= Settings.company_address
        @data[:balance] = @member_account.balance
        @data[:account_transaction] = @account_transaction
      @data
    end
  end
end

