class InsuranceAccountsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def show
    @insurance_account  = MemberAccount.insurance.where(id: params[:id]).first

    @account_transactions = AccountTransaction.where(
                              subsidiary_id: @insurance_account.id
                            ).order("transacted_at ASC")
  end
  def claims_copy_pdf

  	@insurance_account = MemberAccount.find(params[:insurance_account_id])
  	@member = @insurance_account.member
    @lif = "Life Insurance Fund"
    @lif_insurance_account = MemberAccount.where(account_subtype: @lif, member_id: @member.id).first
    @rf = "Retirement Fund"
    @rf_insurance_account = MemberAccount.where(account_subtype: @rf, member_id: @member.id).first

    @payment_meta = Insurance::GenerateInsuranceAccountDetailsForLifAndRf.new(
                      member: @member, 
                      lif_insurance_account: @lif_insurance_account, 
                      rf_insurance_account: @rf_insurance_account
                    ).execute!
  end

  def insurance_account_pdf
    @insurance_account = MemberAccount.find(params[:id])
    @insurance_account_transactions = AccountTransaction.where(
                                        "subsidiary_id = ? AND amount > 0 AND status IN (?)", 
                                        @insurance_account.id, ["approved", "reversed"]
                                      ).order("transacted_at ASC")

  
    if params[:start_date].present? and params[:end_date].present?
      @start_date = params[:start_date]
      @end_date = params[:end_date]

      @insurance_account_transactions = @insurance_account_transactions.where(transacted_at: @start_date..@end_date)
    end

    if params[:status].present?
      @status = params[:status]
      @insurance_account_transactions = @insurance_account_transactions.where(status: @status)
    end

    # @insurance_account_transactions = @insurance_account_transactions

    @payment_meta = Insurance::GenerateInsuranceAccountStatus.new(insurance_account: @insurance_account).execute!
 
  end
end
