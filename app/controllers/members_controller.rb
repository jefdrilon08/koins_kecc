class MembersController < ApplicationController
  before_action :authenticate_user!

  def index
    @members  = Member.select("*")
                      .includes(:center, :branch, :profile_picture_attachment)
                      .where(branch_id: @branches.pluck(:id))
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

    #@members  = @members.order("status ASC, last_name ASC").page(params[:page]).per(LIST_PAGE_SIZE)
    @members  = @members.order("status ASC, last_name ASC").page(params[:page]).per(50)
    @subheader_items = [
      { text: "Members" },
    ]

    @subheader_side_actions = [
      { id: "", link: member_form_path, class: "fa fa-plus", text: "New Member" }
    ]
  end

  def form_resignation
    @member = Member.find(params[:id])

    @subheader_items = [
      { is_link: true, path: members_path, text: "Members" },
      { is_link: true, path: member_path(@member), text: "#{@member.full_name}" },
      { text: "Resignation Form" }
    ]

    @subheader_side_actions = [
    ]

    @payload = {
      id: @member.id,
      memberResignationTypes: helpers.member_resignation_types
    }
  end

  def form_attachment
    @member = Member.find(params[:id])
  end

  def form
    # subheader items
    @subheader_items = [
      {
        is_link: true,
        path: members_path,
        text: "Members"
      },
      {
        text: "Form"
      }
    ]

    @payload = {
      "id": params[:id],
      "memberTypes": Settings.default_member_types
    }
  end

  def blip_form_pdf
    @member = Member.find(params[:id])
  end
  
  def member_registry_excel

    excel = ::Members::GenerateRegistryOfMembers.new(branch: @branches).execute!
    filename  = "member_registry.xlsx"
    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

  end


  def survey_answer
    @member         = Member.find(params[:id])
    @survey_answer  = SurveyAnswer.find(params[:survey_answer_id])
    @data           = @survey_answer.data.with_indifferent_access

    # subheader items
    @subheader_items = [
      {
        is_link: true,
        path: members_path,
        text: "Members"
      },
      {
        is_link: true,
        path: member_path(@member.id),
        text: "#{@member.full_name}"
      },
      {
        text: "#{@survey_answer.survey.name}"
      }
    ]

    @subheader_side_actions = [
      {
        class: "fa fa-pencil-alt",
        link: member_survey_answer_form_path(@member, @survey_answer),
        text: "Edit"
      },
      {
        class: "fa fa-times",
        link: "#",
        id: "btn-delete-survey-answer",
        text: "Delete"
      }
    ]

    @payload = {
      id: @survey_answer.id,
      memberId: @member.id
    }
  end

  def survey_answer_form
    @member         = Member.find(params[:id])
    @survey_answer  = SurveyAnswer.find(params[:survey_answer_id])

    # subheader items
    @subheader_items = [
      {
        is_link: true,
        path: members_path,
        text: "Members"
      },
      {
        is_link: true,
        path: member_path(@member.id),
        text: "#{@member.full_name}"
      },
      {
        is_link: true,
        path: member_survey_answer_path(@member, @survey_answer) ,
        text: "#{@survey_answer.survey.name}"
      },
      {
        text: "Edit"
      }
    ]

    @subheader_side_actions = []

    @payload = {
      id: @survey_answer.id,
      memberId: @member.id
    }
  end

  def show
    @member           = Member.find(params[:id])
    #raise @member[:data].inspect
    @data             = @member.data.with_indifferent_access
    @address          = @data[:address]
    @addressVal       = [@address[:street],@address[:district],@address[:city]]
    @recognition_date = @data[:recognition_date]
    @active_loans     = Loan.active.includes(:loan_product).where(member_id: params[:id]).order("loan_products.name ASC, loans.cycle ASC")
    @paid_loans       = Loan.paid.includes(:loan_product).where(member_id: params[:id]).order("loan_products.name ASC, loans.cycle ASC")
    @pending_loans    = Loan.pending.includes(:loan_product).where(member_id: params[:id]).order("loan_products.name ASC, loans.cycle ASC")

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

    @payload = {
      "memberId": @member.id
    }

    # subheader items
    @subheader_items = [
      {
        is_link: true,
        path: members_path,
        text: "Members"
      },
      {
        text: "#{@member.full_name}"
      }
    ]

    @subheader_side_actions = [
      {
        id: "btn-create-survey",
        class: "fa fa-plus",
        link: "#",
        text: "New Survey"
      }
    ]

    if (Settings.activate_microloans and @member.pending?) or (Settings.activate_microinsurance and @member.pending_dormant?)
      @subheader_side_actions << {
        id: "btn-delete",
        class: "fa fa-times",
        link: "#",
        text: "Delete"
      }
    end

    if @member.active?
      @subheader_side_actions << {
        class: "fa fa-plus",
        link: loan_application_form_path(member_id: @member.id),
        text: "New Loan"
      }
    end
  end

  def import_members
    file = params[:file]
    orig_file_name = file.original_filename
    orig_file_name_no_ext = File.basename("#{orig_file_name}", ".*")
    file_name = orig_file_name_no_ext.delete! "members"
    start_date_string = file_name.split("_").first
    end_date_string = file_name.split("_").last
    
    if !start_date_string.nil? && !end_date_string.nil?
      # if start_date_string.include? "201"
        end_date = DateTime.parse(end_date_string).try(:to_date)
        start_date = DateTime.parse(start_date_string).try(:to_date)
      # else
      #   end_date = nil
      #   start_date = nil
      # end
    else  
      end_date = nil
      start_date = nil
    end

    CSV.foreach(file.path, {:headers => true, :encoding => 'windows-1251:utf-8'}) do |row|
      config = {  
        member: row.to_hash
      }

      @errors = Members::ValidateImportMembersFromCsvFile.new(config: config).execute!
    end

    if !@errors.nil?
      if @errors[:messages].any?
        content = "ERROR: #{@errors[:messages]}!"
        
        ActivityLog.create!(
          content: content,
          activity_type: "upload",
          data: {
            user_id: current_user.id,
            start_date: start_date,
            end_date: end_date
          }
        )
        
        redirect_to import_members_path, :flash => { :error => "#{@errors[:messages].last[:message]}!" }
      else
        Members::ImportMembersFromCsvFile.new(
                            file: file,
                            user: current_user
                      ).execute!
        flash[:success] = "Successfully Imported Members Record."
        
        if !start_date.nil? && !end_date.nil?
          content = "#{current_user.full_name} successfully imported members. #{start_date.strftime("%b %d, %Y")} - #{end_date.strftime("%b %d, %Y")}"
        else
          content = "#{current_user.full_name} successfully imported members."
        end

        ActivityLog.create!(
          content: content,
          activity_type: "upload",
          data: {
            user_id: current_user.id,
            start_date: start_date,
            end_date: end_date
          }
        )

        redirect_to members_path
      end
    else
      content = "Successfully, but no members uploaded!"

      ActivityLog.create!(
          content: content,
          activity_type: "upload",
          data: {
            user_id: current_user.id,
            start_date: start_date,
            end_date: end_date
          }
        )

      redirect_to members_path
    end    
  end

  def import_legal_dependents
    file = params[:file]
    orig_file_name = file.original_filename
    orig_file_name_no_ext = File.basename("#{orig_file_name}", ".*")
    file_name = orig_file_name_no_ext.delete! "legal dependents"
    start_date_string = file_name.split("_").first
    end_date_string = file_name.split("_").last
    
    if !start_date_string.nil? && !end_date_string.nil?
      # if start_date_string.include? "201"
        end_date = DateTime.parse(end_date_string).try(:to_date)
        start_date = DateTime.parse(start_date_string).try(:to_date)
      # else
      #   end_date = nil
      #   start_date = nil
      # end
    else  
      end_date = nil
      start_date = nil
    end

    CSV.foreach(file.path, {:headers => true, :encoding => 'windows-1251:utf-8'}) do |row|
      config = {  
        legal_dependent: row.to_hash
      }

      @errors = Members::ValidateImportLegalDependentsFromCsvFile.new(config: config).execute!
    end

    if !@errors.nil?
      if @errors[:messages].any?
        content = "ERROR: #{@errors[:messages]}!"
        
        ActivityLog.create!(
          content: content,
          activity_type: "upload",
          data: {
            user_id: current_user.id,
            start_date: start_date,
            end_date: end_date
          }
        )

        redirect_to import_legal_dependents_path, :flash => { :error => "#{@errors[:messages].last[:message]}!" }
      else
        Members::ImportLegalDependentsFromCsvFile.new(
                            file: file
                      ).execute!
        flash[:success] = "Successfully Imported Legal Dependents Record."

        if !start_date.nil? && !end_date.nil?
          content = "#{current_user.full_name} successfully imported legal dependents. #{start_date.strftime("%b %d, %Y")} - #{end_date.strftime("%b %d, %Y")}"
        else
          content = "#{current_user.full_name} successfully imported legal dependents."
        end

        ActivityLog.create!(
          content: content,
          activity_type: "upload",
          data: {
            user_id: current_user.id,
            start_date: start_date,
            end_date: end_date
          }
        )

        redirect_to members_path
      end
    else
      content = "Successfully, but no legal dependents uploaded!"

      ActivityLog.create!(
          content: content,
          activity_type: "upload",
          data: {
            user_id: current_user.id,
            start_date: start_date,
            end_date: end_date
          }
        )

      redirect_to members_path
    end
  end

  def import_beneficiaries
    file = params[:file]
    orig_file_name = file.original_filename
    orig_file_name_no_ext = File.basename("#{orig_file_name}", ".*")
    file_name = orig_file_name_no_ext.delete! "beneficiaries"
    start_date_string = file_name.split("_").first
    end_date_string = file_name.split("_").last
    
    if !start_date_string.nil? && !end_date_string.nil?
      # if start_date_string.include? "201"
        end_date = DateTime.parse(end_date_string).try(:to_date)
        start_date = DateTime.parse(start_date_string).try(:to_date)
      # else
      #   end_date = nil
      #   start_date = nil
      # end
    else  
      end_date = nil
      start_date = nil
    end

    CSV.foreach(file.path, {:headers => true, :encoding => 'windows-1251:utf-8'}) do |row|
      config = {  
        beneficiary: row.to_hash
      }

      @errors = Members::ValidateImportBeneficiariesFromCsvFile.new(config: config).execute!
    end

    if !@errors.nil?
      if @errors[:messages].any?
        content = "ERROR: #{@errors[:messages]}!"
        
        ActivityLog.create!(
          content: content,
          activity_type: "upload",
          data: {
            user_id: current_user.id,
            start_date: start_date,
            end_date: end_date
          }
        )

        redirect_to import_beneficiaries_path, :flash => { :error => "#{@errors[:messages].last[:message]}!" }
      else
        Members::ImportBeneficiariesFromCsvFile.new(
                            file: file
                      ).execute!
        flash[:success] = "Successfully Imported Beneficiaries Record."

        if !start_date.nil? && !end_date.nil?
          content = "#{current_user.full_name} successfully imported beneficiaries. #{start_date.strftime("%b %d, %Y")} - #{end_date.strftime("%b %d, %Y")}"
        else
          content = "#{current_user.full_name} successfully imported beneficiaries."
        end

        ActivityLog.create!(
          content: content,
          activity_type: "upload",
          data: {
            user_id: current_user.id,
            start_date: start_date,
            end_date: end_date
          }
        )

        redirect_to members_path
      end
    else
      content = "Successfully, but no beneficiaries uploaded!"

      ActivityLog.create!(
          content: content,
          activity_type: "upload",
          data: {
            user_id: current_user.id,
            start_date: start_date,
            end_date: end_date
          }
        )

      redirect_to members_path
    end  
  end
end
