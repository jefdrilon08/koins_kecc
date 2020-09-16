class ClaimsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_defaults

  def blip_validation_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def blip_loa_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def calamity_validation_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def calamity_loa_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def clip_validation_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end


  def clip_loa_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}

    # if params[:type_of_insurance_policy].present?
    #   @type_of_insurance_policy = params[:type_of_insurance_policy]
    #   @claims = @claims.where(type_of_insurance_policy: @type_of_insurance_policy)
    # end
  
    #  @claims = @claims.page(params[:page]).per(LIST_PAGE_SIZE)

  end

  def hiip_validation_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def hiip_loa_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def kalinga_validation_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def kalinga_loa_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def kbente_validation_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def kbente_loa_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def scholarship_validation_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def scholarship_contract_highschool_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def scholarship_contract_college_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def scholarship_loa_pdf
    @claim = Claim.find(params[:claim_id])
    @data  = @claim.data.try(:with_indifferent_access) || {}
  end

  def new
    @claim = Claim.find(params[:id])

    @payload = {
      id: @claim.id
    }

    @subheader_items = [
      { is_link: true, path: claims_path, text: "Claims" },
      { is_link: true, path: member_path(@claim.member), text: "#{@claim.member.full_name}" }
    ]

    @subheader_side_actions = []
    
    @subheader_side_actions << {
        link: claim_path(@claim),
        class: "fa fa-times",
        data: { method: :delete, confirm: "Are you sure?" },
        text: "Delete"
    }

    @subheader_side_actions << {
        link: claims_path,
        class: "fa fa-arrow-left",
        text: "Back to Claims"
    }
  end

  def edit
    @claim = Claim.find(params[:id])

    @payload = {
      id: @claim.id
    }

    @subheader_items = [
      { is_link: true, path: claims_path, text: "Claims" },
      { is_link: true, path: member_path(@claim.member), text: "#{@claim.member.full_name}" }
    ]

    @subheader_side_actions = []
    
    @subheader_side_actions << {
        link: claim_path(@claim),
        class: "fa fa-times",
        data: { method: :delete, confirm: "Are you sure?" },
        text: "Delete"
    }
    @subheader_side_actions << {
        link: claims_path,
        class: "fa fa-arrow-left",
        text: "Back to Claims"
    }
  end

  def index
    @claims = Claim.all.includes(:member, :branch).where(branch_id: @branches.pluck(:id)).order("date_prepared DESC")

    if params[:member].present?
      @member = params[:member]
      @claims = @claims.joins(:member).where("lower(members.first_name) LIKE :member OR lower(members.last_name) LIKE :member OR lower(members.middle_name) LIKE :member", member: "%#{@member.downcase}%")
    end

    if params[:branch_id].present?
      @branch = Branch.find(params[:branch_id])
      @claims = @claims.where(branch_id: @branch.id)
    end

    if params[:claim_type].present?
      @claim_type = params[:claim_type]
      @claims = @claims.where(claim_type: @claim_type)
    end

    if params[:status].present?
      @status = params[:status]
      @claims = @claims.where(status: @status)
    end
  
    @claims = @claims.page(params[:page]).per(25)

    @subheader_items = [
      {
        text: "Microinsurance"
      },
      {
        text: "Claims Register"
      }
    ]

    @subheader_side_actions = [
      {
        id: "btn-new-transaction",
        link: "#",
        class: "fa fa-plus",
        text: "New Claims"
      }
    ]

  end
  
  def destroy
    @claim = Claim.find(params[:id])
    @claim.destroy!
    flash[:success] = "Successfully removed claim"
    redirect_to claims_path
  end

  def show
    @claim            = Claim.find(params[:id])
    @data             = @claim.data.try(:with_indifferent_access) || {}

    @subheader_items = [
      { is_link: true, path: claims_path, text: "Claims" },
      { is_link: true, path: member_path(@claim.member), text: "#{@claim.member.full_name}" }
    ]

    @subheader_side_actions = []
    if @claim.pending?
      @subheader_side_actions << {
          id: "approved-button",
          link: "#",
          class: "fa fa-check",
          text: "Approve"
      }

      @subheader_side_actions << {
        link: edit_claim_path(@claim),
        class: "fa fa-edit",
        text: "Edit"
      }

      @subheader_side_actions << {
        link: claim_path(@claim),
        class: "fa fa-times",
        data: { method: :delete, confirm: "Are you sure?" },
        text: "Delete"
      } 
    end

    if @claim.claim_type == "BLIP" and @claim.approved?
      @subheader_side_actions << {
        link: edit_claim_path(@claim),
        class: "fa fa-edit",
        text: "Edit"
      }

      @subheader_side_actions << {
        link: claim_blip_validation_pdf_path(@claim),
        class: "fa fa-print",
        text: "Validation PDF"
      }

      @subheader_side_actions << {
        link: claim_blip_loa_pdf_path(@claim),
        class: "fa fa-print",
        text: "LOA"
      }
    end

    if @claim.claim_type == "CLIP" and @claim.approved?
      @subheader_side_actions << {
        link: edit_claim_path(@claim),
        class: "fa fa-edit",
        text: "Edit"
      }

      @subheader_side_actions << {
        link: claim_clip_validation_pdf_path(@claim),
        class: "fa fa-print",
        text: "Validation PDF"
      }

      @subheader_side_actions << {
        link: claim_clip_loa_pdf_path(@claim),
        class: "fa fa-print",
        text: "LOA"
      }
    end

    if @claim.claim_type == "CALAMITY ASSISTANCE" and @claim.approved?
      @subheader_side_actions << {
        link: edit_claim_path(@claim),
        class: "fa fa-edit",
        text: "Edit"
      }

      @subheader_side_actions << {
        link: claim_calamity_validation_pdf_path(@claim),
        class: "fa fa-print",
        text: "Validation PDF"
      }

      @subheader_side_actions << {
        link: claim_calamity_loa_pdf_path(@claim),
        class: "fa fa-print",
        text: "LOA"
      }
    end

    if @claim.claim_type == "HIIP" and @claim.approved?
      @subheader_side_actions << {
        link: edit_claim_path(@claim),
        class: "fa fa-edit",
        text: "Edit"
      }

      @subheader_side_actions << {
        link: claim_hiip_validation_pdf_path(@claim),
        class: "fa fa-print",
        text: "Validation PDF"
      }

      @subheader_side_actions << {
        link: claim_hiip_loa_pdf_path(@claim),
        class: "fa fa-print",
        text: "LOA"
      }
    end

    if @claim.claim_type == "K-KALINGA" and @claim.approved?
      @subheader_side_actions << {
        link: edit_claim_path(@claim),
        class: "fa fa-edit",
        text: "Edit"
      }

      @subheader_side_actions << {
        link: claim_kalinga_validation_pdf_path(@claim),
        class: "fa fa-print",
        text: "Validation PDF"
      }

      @subheader_side_actions << {
        link: claim_kalinga_loa_pdf_path(@claim),
        class: "fa fa-print",
        text: "LOA"
      }
    end

    if @claim.claim_type == "K-BENTE" and @claim.approved?
      @subheader_side_actions << {
        link: edit_claim_path(@claim),
        class: "fa fa-edit",
        text: "Edit"
      }

      @subheader_side_actions << {
        link: claim_kbente_validation_pdf_path(@claim),
        class: "fa fa-print",
        text: "Validation PDF"
      }

      @subheader_side_actions << {
        link: claim_kbente_loa_pdf_path(@claim),
        class: "fa fa-print",
        text: "LOA"
      }
    end

    if @claim.claim_type == "KUYA JUN SCHOLARSHIP PROGRAM" and @claim.approved?
      @subheader_side_actions << {
        link: edit_claim_path(@claim),
        class: "fa fa-edit",
        text: "Edit"
      }

      if @claim.data["year_level"] == "GRADE 7" || @claim.data["year_level"] == "GRADE 8" || @claim.data["year_level"] == "GRADE 9" || @claim.data["year_level"] == "GRADE 10" || @claim.data["year_level"] == "GRADE 11" || @claim.data["year_level"] == "GRADE 12"
        @subheader_side_actions << {
          link: claim_scholarship_contract_highschool_pdf_path(@claim),
          class: "fa fa-print",
          text: "Scholarship Contract for Highschool"
        }
      else
        @subheader_side_actions << {
          link: claim_scholarship_contract_college_pdf_path(@claim),
          class: "fa fa-print",
          text: "Scholarship Contract for College"
        }
      end

      @subheader_side_actions << {
        link: claim_scholarship_validation_pdf_path(@claim),
        class: "fa fa-print",
        text: "Validation PDF"
      }

      @subheader_side_actions << {
        link: claim_scholarship_loa_pdf_path(@claim),
        class: "fa fa-print",
        text: "LOA"
      }
    end

    @subheader_side_actions << {
        link: claims_path,
        class: "fa fa-arrow-left",
        text: "Back to Claims"
    }
  end
end
