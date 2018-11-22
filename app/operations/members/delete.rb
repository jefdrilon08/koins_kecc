module Members
  class Delete  < AppValidator
    def initialize(config:)
      @config = config
      @member = @config[:member]
      @user   = @config[:user]
    end

    def execute!
      # Delete accounts
      @member.member_accounts.delete_all

      # Dleete legal dependents
      @member.legal_dependents.delete_all

      # Delete beneficiaries
      @member.beneficiaries.delete_all

      # Delete members
      @member.destroy!
    end
  end
end
