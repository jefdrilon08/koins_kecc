class MembersController < ApplicationController
  before_action :authenticate_user!

  def index
    @members  = Member.select("*").where(branch_id: @branches.pluck(:id))
    @q        = params[:q]
    @status   = params[:status]
    @center   = Center.where(id: params[:center_id]).first
    @branch   = Branch.where(id: params[:branch_id]).first

    @centers  = @branches.first.centers

    if @q.present?
      @members  = @members.where(
                    "upper(first_name) LIKE :q OR upper(last_name) LIKE :q OR upper(identification_number) LIKE :q",
                    q: "%#{@q.upcase}%"
                  )
    end

    if @branch.present?
      @members  = @members.where(branch_id: @branch.id)
    end

    if @center.present?
      @members  = @members.where(center_id: @center.id)
    end

    if @status.present?
      @members  = @members.where(status: @status)
    end

    @members  = @members.order("last_name ASC").page(params[:page]).per(20)
  end

  def form_resignation
    @member = Member.find(params[:id])
  end

  def form
  end

  def survey_answer
    @member         = Member.find(params[:id])
    @survey_answer  = SurveyAnswer.find(params[:survey_answer_id])
    @data           = @survey_answer.data.with_indifferent_access
  end

  def survey_answer_form
    @member         = Member.find(params[:id])
    @survey_answer  = SurveyAnswer.find(params[:survey_answer_id])
  end

  def show
    @member = Member.find(params[:id])
    @data   = @member.data.with_indifferent_access

    @active_loans   = Loan.active.where(member_id: params[:id])
    @paid_loans     = Loan.paid.where(member_id: params[:id])
    @pending_loans  = Loan.pending.where(member_id: params[:id])

    @savings_accounts   = MemberAccount.savings.where(member_id: @member.id)
    @insurance_accounts = MemberAccount.insurance.where(member_id: @member.id)
    @equity_accounts    = MemberAccount.equities.where(member_id: @member.id)
    

    @member_shares  = @member.member_shares.order("created_at ASC")

    @surveys        = Survey.all.order("name ASC")
    @survey_answers = SurveyAnswer.where(
                        "meta -> 'member' ->> 'id' = ?",
                        @member.id
                      ).order("updated_at DESC")

    @loan_balance = @active_loans.sum("principal_balance + interest_balance")

    @loan_products  = LoanProduct.select("*").order("name ASC")

    @activity_logs  = ActivityLog.where(
                        "data ->> 'member_id' = ?",
                        @member.id
                      ).order("created_at DESC")

    @loan_cycles  = @member.data.with_indifferent_access[:loan_cycles]

    @missing_accounts = ::Members::FetchMissingAccounts.new(
                          config: {
                            member: @member
                          }
                        ).execute!
  end
end
