class MembersController < ApplicationController
  before_action :authenticate_user!

  def index
    @members  = Member.select("*").where(branch_id: @branches.pluck(:id))
    @q        = params[:q]
    @status   = params[:status]
    @restored = params[:restored].present?
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

    if @restored.present?
      @members  = @members.where("data->'restoration_records' IS NOT NULL")
    end

    @members  = @members.order("status ASC, last_name ASC").page(params[:page]).per(100)
  end

  def form_resignation
    @member = Member.find(params[:id])
  end

  def form_attachment
    @member = Member.find(params[:id])
  end

  def form
  end

  def blip_form_pdf
    @member = Member.find(params[:id])
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
    @member           = Member.find(params[:id])
    #raise @member[:data].inspect
    @data             = @member.data.with_indifferent_access
    @address          = @data[:address]
    @addressVal       = [@address[:street],@address[:district],@address[:city]]
    @recognition_date = @data[:recognition_date]
    @active_loans   = Loan.active.where(member_id: params[:id])
    @paid_loans     = Loan.paid.where(member_id: params[:id])
    @pending_loans  = Loan.pending.where(member_id: params[:id])

    @savings_accounts   = MemberAccount.savings.where(member_id: @member.id)
    @insurance_accounts = MemberAccount.insurance.where(member_id: @member.id)
    @equity_accounts    = MemberAccount.equities.where(member_id: @member.id)
    

    @member_shares  = @member.member_shares.order("created_at ASC")

    @membership_payments  = @member.membership_payment_records.where("amount > 0").order("date_paid ASC")

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

  def import_members
    file = params[:file]

    CSV.foreach(file.path, {:headers => true, :encoding => 'windows-1251:utf-8'}) do |row|
      config = {  
        member: row.to_hash
      }

      @errors = Members::ValidateImportMembersFromCsvFile.new(config: config).execute!
    end

    if @errors[:messages].size > 0
      redirect_to import_members_path, :flash => { :error => "#{@errors[:messages].last[:message]}!" }
    else
      Members::ImportMembersFromCsvFile.new(
                          file: file
                    ).execute!
      flash[:success] = "Successfully Imported Members Record."
      redirect_to members_path
    end  
  end

  def import_legal_dependents
    file = params[:file]

    CSV.foreach(file.path, {:headers => true, :encoding => 'windows-1251:utf-8'}) do |row|
      config = {  
        legal_dependent: row.to_hash
      }

      @errors = Members::ValidateImportLegalDependentsFromCsvFile.new(config: config).execute!
    end

    if @errors[:messages].size > 0
      redirect_to import_legal_dependents_path, :flash => { :error => "#{@errors[:messages].last[:message]}!" }
    else
      Members::ImportLegalDependentsFromCsvFile.new(
                          file: file
                    ).execute!
      flash[:success] = "Successfully Imported Legal Dependents Record."
      redirect_to members_path
    end  
  end

  def import_beneficiaries
    file = params[:file]

    CSV.foreach(file.path, {:headers => true, :encoding => 'windows-1251:utf-8'}) do |row|
      config = {  
        beneficiary: row.to_hash
      }

      @errors = Members::ValidateImportBeneficiariesFromCsvFile.new(config: config).execute!
    end

    if @errors[:messages].size > 0
      redirect_to import_beneficiaries_path, :flash => { :error => "#{@errors[:messages].last[:message]}!" }
    else
      Members::ImportBeneficiariesFromCsvFile.new(
                          file: file
                    ).execute!
      flash[:success] = "Successfully Imported Beneficiaries Record."
      redirect_to members_path
    end  
  end
end
