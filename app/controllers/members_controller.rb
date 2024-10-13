class MembersController < ApplicationController
  before_action :authenticate_user!

  def search
    @subheader_items = [
      { text: "Members", is_link: true, path: members_path },
      { text: "Search" }
    ]

    @subheader_side_actions = [
    ]
  end

  def index
    @members  = Member.select("*")
                      .includes(:center, :branch, :profile_picture_attachment)
                      .where(branch_id: @branches.pluck(:id))

    @q                  = params[:q]
    @insurance_status   = params[:insurance_status]
    @status             = params[:status]
    @restored           = params[:restored].present?
    @center             = Center.where(id: params[:center_id]).try(:first)
    @branch             = Branch.where(id: params[:branch_id]).try(:first)
    @centers            = @branches.first.try(:centers) || []

    if @q.present?
      @members = @members.where(
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

    if @insurance_status.present?
      @members  = @members.where(insurance_status: @insurance_status)
    end

    if @restored.present?
      @members  = @members.where("data->'restoration_records' IS NOT NULL")
    end

    @members  = @members.order("status ASC, last_name ASC").page(params[:page]).per(LIST_PAGE_SIZE)

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
      "memberTypes": Settings.default_member_types,
      "membershipArrangements": MembershipArrangement.all.map{ |o| { id: o.id, name: o.name } },
      "membershipTypes": MembershipType.all.map{ |o| { id: o.id, name: o.name } },
      "referrers": Referrer.where(category: "REFERRER", status: "active").map{ |o| { id: o.id, name: o.full_name } },
      "coordinators": Referrer.where(category: "INSURANCE COORDINATOR", status: "active").map{ |o| { id: o.id, name: o.full_name } }
    }
  end

  def blip_form_pdf
    @member = Member.find(params[:id])

    @user_roles = UserBranch.joins(:user).where("branch_id = ? AND active = true", @member.branch_id).pluck(:user_id).uniq
    @user_roles.each do |y|
      user = User.find(y)
        if user.current_roles.shift == "FM"
          @som = user[:first_name].upcase + " "+ user[:last_name].upcase
        end
      end
  end

  def claims_copy_pdf
    @member = Member.find(params[:id])
    @member_id = @member[:id]  
    @insurance_account = MemberAccount.where(member_id: @member_id)
    @lif = "Life Insurance Fund"
    @lif_insurance_account = MemberAccount.where(account_subtype: @lif, member_id: @member_id).first
    @rf = "Retirement Fund"
    @rf_insurance_account = MemberAccount.where(account_subtype: @rf, member_id: @member_id).first
    @date_of_death = session[:date_of_death].to_date
    
    config = {
      member: @member,
      lif_insurance_account: @lif_insurance_account,
      rf_insurance_account: @rf_insurance_account,
      date_of_death: @date_of_death
    }

    @payment_meta = Members::GenerateInsuranceAccountDetailsForLifAndRf.new(
      config: config
    ).execute!
  end
  
  def member_registry_excel

    excel = ::Members::GenerateRegistryOfMembers.new(branch: @branches).execute!
    filename  = "member_registry.xlsx"
    excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

  end

  def form_make_payments
    
    @member = Member.find(params[:id]) 
    config = {
                member_id: @member.id,
                make_payment_type: params[:type]
      
              }
    @data = ::Members::BuildMakePayments.new(config: config).execute!

    @accounting_entry = ::Members::BuildAccountingEntryForMakePayments.new(
                                    make_payment_data: @data, 
                                    current_user: current_user,
                                    make_payment_type: params[:type]

                                    ).execute!

    @subheader_items = [
      { is_link: true, path: members_path, text: "Members" },
      { is_link: true, path: member_path(@member), text: "#{@member.full_name}" },
      { text: "Make Payment Form" }
    ]

  
    @subheader_side_actions = [
      {
        id: "btn-save",
        link: "#",
        class: "fa fa-check",
        text: "Save",
      
        data: { member_id: @member.id, make_payment_type: params[:type] }
      },
      { 
        is_link: true, 
        link: "/members/" + @member.id + "/display",
        # path: member_path(@member), 
        class: "fa fa-times",
        text: "Cancel" }
    ]
    @payload = {
      id: @member.id,
      memberResignationTypes: helpers.member_resignation_types
    }
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
    @member             = Member.find(params[:id])
    @data               = @member.data.with_indifferent_access
    @address            = @data[:address]
    @addressVal         = [@address[:street],@address[:district],@address[:city],@address[:province],@address[:region]]
    @recognition_date   = @data[:recognition_date]

    @savings_accounts = MemberAccount.savings.where(
      member_id: @member.id
    )

    @insurance_accounts = MemberAccount.insurance.where(
      member_id: @member.id
    )

    @equity_accounts = MemberAccount.equities.where(
      member_id: @member.id
    )

    @member_shares = @member.member_shares.order("created_at ASC").map{ |o|
      {
        id:                 o.id,
        date_of_issue:      o.date_of_issue.strftime("%b %d, %Y"),
        certificate_number: o.certificate_number,
        certificate_for:    o.certificate_for,
        is_void:            o.is_void,
        number_of_shares:   o.number_of_shares
      }
    }

    @membership_payments = @member.membership_payment_records.where(
      "amount > 0"
    ).order(
      "date_paid ASC"
    ).map{ |o|
      {
        id:               o.id,
        date_paid:        o.date_paid.strftime("%b %d, %Y"),
        membership_name:  o.membership_name,
        membership_type:  o.membership_type,
        amount:           view_context.number_to_currency(o.amount, unit: ''),
        status:           o.status
      }
    }

    @surveys = Survey.all.order("name ASC").map{ |o|
      {
        id: o.id,
        name: o.name
      }
    }

    @survey_answers = SurveyAnswer.where(
      "meta -> 'member' ->> 'id' = ?",
      @member.id
    ).order("updated_at DESC").map{ |o|
      {
        id:           o.id,
        survey_name:  o.survey.name,
        updated_at:   o.updated_at.localtime.strftime("%b %d, %Y")
      }
    }

    @active_loans = ReadOnlyLoan.active.includes(:loan_product).where(
      member_id: params[:id]
    ).order(
      "loan_products.name ASC, loans.cycle ASC"
    )

    @accrued_interest = ReadOnlyLoan.includes(:loan_product).where(
      "data ->> 'accrued_interest' is not null and member_id = ?" ,params[:id]
    )

    @for_verification_loans = ReadOnlyLoan.for_verification.includes(:loan_product).where(
      member_id: params[:id]
    ).order(
      "loan_products.name ASC"
    )
  

    @paid_loans = ReadOnlyLoan.paid.includes(:loan_product).where(
      member_id: params[:id]
    ).order(
      "loan_products.name ASC, loans.cycle ASC"
    )

    @pending_loans = ReadOnlyLoan.pending.includes(:loan_product).where(
      member_id: params[:id]
    ).order(
      "loan_products.name ASC, loans.cycle ASC"
    )

    @verified_loans = ReadOnlyLoan.verified.includes(:loan_product).where(
      member_id: params[:id]
    ).order(
      "loan_products.name ASC"
    )

    @in_process_loans = ReadOnlyLoan.in_process.includes(:loan_product).where(
      member_id: params[:id]
    ).order(
      "loan_products.name ASC"
    )

    @writeoff_loans = ReadOnlyLoan.writeoff.includes(:loan_product).where(
      member_id: params[:id]
    ).order(
      "loan_products.name ASC, loans.cycle ASC"
    )

    @for_writeoff_loans = ReadOnlyLoan.for_writeoff.includes(:loan_product).where(
      member_id: params[:id]
    ).order(
      "loan_products.name ASC, loans.cycle ASC"
    )

    @loan_balance = @active_loans.sum("principal_balance + interest_balance")

    @loan_products  = ReadOnlyLoanProduct.select("*").order("name ASC")

    @loan_cycles  = @member.data.with_indifferent_access[:loan_cycles]

    @missing_accounts = ::Members::FetchMissingAccounts.new(
      config: {
        member: @member
      }
    ).execute!

    @legal_dependents = @member.legal_dependents.map{ |o|
      {
        id:                     o.id,
        full_name:              o.full_name,
        date_of_birth:          o.try(:date_of_birth).try(:strftime, "%b %d, %Y"),
        age:                    o.age,
        relationship:           o.relationship,
        educational_attainment: o.data['educational_attainment'],
        course:                 o.data['course'],
        gender:                 o.gender
      }
    }

    @beneficiaries = @member.beneficiaries.map{ |o|
      {
        id:             o.id,
        is_primary:     o.is_primary,
        full_name:      o.full_name,
        date_of_birth:  o.try(:date_of_birth).try(:strftime, "%b %d, %Y"),
        age:            o.age,
        relationship:   o.relationship
      }
    }
@accrued_interest_data = []
if @accrued_interest.present?
  @accrued_interest_data = @accrued_interest.map{ |o|
    if o[:data]["accrued_interest"].present?
      total_accrued_interest = o[:data]["accrued_interest"]["total_accrued_interest"]
      total_accrued_interest_balance = o[:data]["accrued_interest"]["total_accrued_interest_balance"]
      status = o[:data]["accrued_interest"]["status"]
      
      if status.blank?
        status = o[:data]["accrued_interest"]["status"] = "active"
      else
  
      end
      
      {
        id:                               o.id,
        pn_number:                        o.pn_number,
        loan_product:                     o.loan_product.name,
        total_accrued_interest:           view_context.number_to_currency(total_accrued_interest, unit: ''),
        total_accrued_interest_balance:   total_accrued_interest_balance,
        total_balance_accrued_interest:   total_accrued_interest,
        status:                           status
      }
    end
  }
end
    @resignation_records = []

    if @data[:resignation_records].present?
      @resignation_records = @data[:resignation_records].map{ |o|
        if o[:data].present?
          {
            date_resigned:  o[:date_resigned].try(:to_date).try(:strftime, "%b %d, %Y"),
            type:           o[:data].present? ? o[:data][:type] : o[:member_resignation_type][:name],
            reason:         o[:data].present? ? o[:data][:reason] : o[:member_resignation_type][:particular][:name]
          }
        end
      }
    end


    @project_type = []

    if @data[:project_type].present?
      @project_type = @data[:project_type].map { |o|
        if o[:details].present?
          {
            project_type_category: o[:details][:project_type_category],
            project_type: o[:details][:project_type]

          }

        end
      }
    end


    @co_makers = ReadOnlyMember.active.where(
      center_id: @member.center_id
    ).where.not(
      id: @member.id
    ).map{ |o|
      {
        id: o.id,
        name: o.full_name
      }
    }

    @payload = {
      "memberId":                     @member.id,
      "member":                       @member,
      "member_age":                   @member.age,
      "date_of_birth":                @member.date_of_birth.strftime("%b %d, %Y"),
      "data":                         @data,
      "branch":                       @member.branch,
      "center":                       @member.center,
      "is_resigned":                  @member.resigned?,
      "profile_picture_url":          @member.profile_picture_url,
      "date_of_membership":           @member.date_of_membership,
      "date_resigned":                @member.date_resigned.try(:strftime, "%b %d, %Y"),
      "previous_date_resigned":       @member.previous_date_resigned.try(:strftime, "%b %d, %Y"),
      "membership_type":              @member.membership_type,
      "membership_arrangement":       @member.membership_arrangement,
      "recognition_date":             @member.recognition_date.try(:strftime, "%b %d, %Y"),
      "length_of_stay":               @member.length_of_stay,
      "face_amount":                  @member.face_amount, 
      "legal_dependents":             @legal_dependents,
      "beneficiaries":                @beneficiaries,
      "resignation_records":          @resignation_records,
      "address":                      @addressVal,
      "entry_point_loan_cycle_count": @member.entry_point_loan_cycle_count,
      "survey_answers":               @survey_answers,
      "token":                        current_user.generate_jwt,
      "total_savings":                view_context.number_to_currency(@savings_accounts.sum(:balance), unit: ''),
      "total_equity":                 view_context.number_to_currency(@equity_accounts.sum(:balance), unit: ''),
      "member_shares":                @member_shares,
      "membership_payments":          @membership_payments,
      "roles":                        current_user.roles,
      "co_makers":                    @co_makers,
      "surveys":                      @surveys,
      "status":                       @member.status,
      "reinstated":                   @member.reinstated.try(:strftime, "%b %d, %Y"),
      "project_type":                 @project_type,
      "accrued_interest_data":        @accrued_interest_data,
      "from_mobile_app":              @member.from_mobile_app  
    }
    
    @payload[:active_loans] = @active_loans.map{ |o|
      {
        id:             o.id,
        pn_number:      o.pn_number,
        loan_product:   o.loan_product.name,
        cycle:          o.cycle,
        total_dues:     view_context.number_to_currency(o.total_dues, unit: ''),
        total_paid:     view_context.number_to_currency(o.total_paid, unit: ''),
        total_balance:  view_context.number_to_currency(o.total_balance, unit: '')
      }
    }

    @payload[:for_verification_loans] = @for_verification_loans.map{ |o|
      {
        id:             o.id,
        pn_number:      o.pn_number,
        loan_product:   o.loan_product.name,
        cycle:          o.cycle,
        total_dues:     view_context.number_to_currency(o.total_dues, unit: ''),
        total_paid:     view_context.number_to_currency(o.total_paid, unit: ''),
        total_balance:  view_context.number_to_currency(o.total_balance, unit: '')
      }
    }

    @payload[:verified_loans] = @verified_loans.map{ |o|
      {
        id:             o.id,
        pn_number:      o.pn_number,
        loan_product:   o.loan_product.name,
        cycle:          o.cycle,
        total_dues:     view_context.number_to_currency(o.total_dues, unit: ''),
        total_paid:     view_context.number_to_currency(o.total_paid, unit: ''),
        total_balance:  view_context.number_to_currency(o.total_balance, unit: '')
      }
    }

    @payload[:in_process_loans] = @in_process_loans.map{ |o|
      {
        id:             o.id,
        pn_number:      o.pn_number,
        loan_product:   o.loan_product.name,
        cycle:          o.cycle,
        total_dues:     view_context.number_to_currency(o.total_dues, unit: ''),
        total_paid:     view_context.number_to_currency(o.total_paid, unit: ''),
        total_balance:  view_context.number_to_currency(o.total_balance, unit: '')
      }
    }

    @payload[:pending_loans] = @pending_loans.map{ |o|
      {
        id:             o.id,
        pn_number:      o.pn_number,
        loan_product:   o.loan_product.name,
        cycle:          o.cycle,
        total_dues:     view_context.number_to_currency(o.total_dues, unit: ''),
        total_paid:     view_context.number_to_currency(o.total_paid, unit: ''),
        total_balance:  view_context.number_to_currency(o.total_balance, unit: '')
      }
    }

    @payload[:paid_loans] = @paid_loans.map{ |o|
      {
        id:             o.id,
        pn_number:      o.pn_number,
        loan_product:   o.loan_product.name,
        cycle:          o.cycle,
        total_dues:     view_context.number_to_currency(o.total_dues, unit: ''),
        total_paid:     view_context.number_to_currency(o.total_paid, unit: ''),
        total_balance:  view_context.number_to_currency(o.total_balance, unit: '')
      }
    }

    @payload[:writeoff_loans] = @writeoff_loans.map{ |o|
      {
        id:             o.id,
        pn_number:      o.pn_number,
        loan_product:   o.loan_product.name,
        cycle:          o.cycle,
        total_dues:     view_context.number_to_currency(o.total_dues, unit: ''),
        total_paid:     view_context.number_to_currency(o.total_paid, unit: ''),
        total_balance:  view_context.number_to_currency(o.total_balance, unit: '')
      }
    }

    @payload[:for_writeoff_loans] = @for_writeoff_loans.map{ |o|
      {
        id:             o.id,
        pn_number:      o.pn_number,
        loan_product:   o.loan_product.name,
        cycle:          o.cycle,
        total_dues:     view_context.number_to_currency(o.total_dues, unit: ''),
        total_paid:     view_context.number_to_currency(o.total_paid, unit: ''),
        total_balance:  view_context.number_to_currency(o.total_balance, unit: '')
      }
    }

   

    @payload[:savings_accounts] = @savings_accounts.map{ |o|
      {
        id:                   o.id,
        type:                 o.account_subtype,
        maintaining_balance:  view_context.number_to_currency(o.maintaining_balance, unit: ''),
        current_balance:      view_context.number_to_currency(o.balance, unit: '')
      }
    }

    @payload[:insurance_accounts] = @insurance_accounts.map{ |o|
      balance = o.balance

      if o.clip
        balance = o.clip_active_balance
      elsif o.hiip
        balance = o.hiip_active_balance
      end

      {
        id:       o.id,
        type:     o.account_subtype,
        balance:  view_context.number_to_currency(balance, unit: '')
      }
    }

    @payload[:equity_accounts] = @equity_accounts.map{ |o|
      {
        id:       o.id,
        type:     o.account_subtype,
        balance:  view_context.number_to_currency(o.balance, unit: '')
      }
    }

    @payload[:total_insurance] = 0.00

    @insurance_accounts.each do |o|
      balance = o.balance

      if o.clip
        balance = o.clip_active_balance
      elsif o.hiip
        balance = o.hiip_active_balance
      end

      @payload[:total_insurance] += balance
    end

    @payload[:total_insurance] = view_context.number_to_currency(@payload[:total_insurance], unit: '')

    if @member.present? && @member.attachment_files.present?
      @payload[:attachment_files] = @member.attachment_files.map{ |o|
        if o.file.present? # Check if file is not nil
          {
            id:         o.id,
            file_name:  o.file_name,
            is_image:   o.file.image?,
            link:       view_context.rails_blob_path(o.file, disposition: "attachment", only_path: true)
          }
        else
          {
            id:         o.id,
            file_name:  o.file_name,
            is_image:   false, # Assuming it's not an image if the file is nil
            link:       nil    # No link if there's no file
          }
        end

        }
    end

    @payload[:loan_products_for_restructuring] = helpers.loan_products_for_restructuring.map{ |o|
      {
        id: o.id,
        name: o.name
      }
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

    @subheader_side_actions = []

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
        end_date = DateTime.parse(end_date_string).to_date
        start_date = DateTime.parse(start_date_string).to_date
      # else
      #   end_date = nil
      #   start_date = nil
      # end
    else  
      end_date = nil
      start_date = nil
    end

    CSV.foreach(file.path, headers: true, encoding: 'windows-1251:utf-8') do |row|
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

    CSV.foreach(file.path, headers: true, encoding: 'windows-1251:utf-8') do |row|
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

    CSV.foreach(file.path, headers: true, encoding: 'windows-1251:utf-8') do |row|
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
