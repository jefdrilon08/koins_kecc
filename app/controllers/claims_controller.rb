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
    @control = "new"

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
    @control = "edit"

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

      if @status == "for checking"
        @status = "pending"
      elsif @status == "for approval"
        @status = "for-approval"
      elsif @status == "for posting"
        @status = "for-posting"
      elsif @status == "posted"
        @status = "approved"
      end

      @claims = @claims.where(status: @status)
    end

    @claims = @claims.page(params[:page]).per(25)

    if ["Silvida"].include? current_user.first_name
      @claims = @claims.where(status: "for-approval").page(params[:page]).per(25)
    end

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
        id: "btn-daily-report",
        class: "fa fa-print",
        link: "#",
        text: "Daily Report"
      },
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
    @member           = @claim.member
    @data             = @claim.data.try(:with_indifferent_access) || {}

    if !@data.nil?
      @accounting_entry_data = @claim.data.with_indifferent_access[:accounting_entry]
    end

    if !@accounting_entry_data.nil?
      @accounting_entry        = AccountingEntry.where(
                                        reference_number: @claim.data.with_indifferent_access[:accounting_entry][:reference_number],
                                        book: @claim.data.with_indifferent_access[:accounting_entry][:book],
                                        branch_id: @claim.data.with_indifferent_access[:accounting_entry][:branch_id],
                                        particular: @claim.data.with_indifferent_access[:accounting_entry][:particular]
                                        ).first
    end

    @subheader_items = [
      {
        is_link: true,
        path: claims_path,
        text: "Claims"
      },
      {
        is_link: true,
        path: member_path(@claim.member),
        text: "#{@claim.member.full_name}"
      },
      {
        is_link: true,
        path: claim_path(@claim),
        class: "btn btn-success",
        text: "#{@claim.status}"
      }
    ]

    @subheader_side_actions = []

    @subheader_side_actions << {
      id: "btn-daily-report",
      class: "fa fa-print",
      link: "#",
      text: "Daily Report"
    }

    if @claim.pending?
      if ["AO"].include? current_user.roles.last
        if @claim.prepared_by == "Richard Monteron"
          if ["Evelyn", "Adrian", "MCQUEN"].include? current_user.first_name
            @subheader_side_actions << {
              id: "btn-check",
              link: "#",
              class: "fa fa-check",
              text: "Check"
            }
          end
        elsif @claim.prepared_by == "Mcquen Abellano"
          if ["Evelyn", "Adrian", "Richard"].include? current_user.first_name
            @subheader_side_actions << {
              id: "btn-check",
              link: "#",
              class: "fa fa-check",
              text: "Check"
            }
          end
        elsif @claim.prepared_by == "Pamel Joseph Julian"
          if ["Evelyn", "Adrian", "Richard", "MCQUEN"].include? current_user.first_name
            @subheader_side_actions << {
              id: "btn-check",
              link: "#",
              class: "fa fa-check",
              text: "Check"
            }
          end
        elsif @claim.prepared_by == "Oliver Purisima"
          if ["Evelyn", "Adrian", "Richard", "MCQUEN"].include? current_user.first_name
            @subheader_side_actions << {
              id: "btn-check",
              link: "#",
              class: "fa fa-check",
              text: "Check"
            }
          end
        elsif @claim.prepared_by == "Adrian San Andres"
          if ["Evelyn", "Richard", "MCQUEN"].include? current_user.first_name
            @subheader_side_actions << {
              id: "btn-check",
              link: "#",
              class: "fa fa-check",
              text: "Check"
            }
          end
        end
      end
    end

    # if @claim.pending? && @claim.proceed_checking?
    #   if ["AO"].include? current_user.roles.last
    #     if ["Aljon", "Adrian", "Diobert"].include? current_user.first_name
    #       @subheader_side_actions << {
    #         id: "btn-declined",
    #         link: "#",
    #         class: "fa fa-check",
    #         text: "Decline"
    #       }
    #     end
    #   end
    # end

    # if @claim.pending? && @claim.proceed_checking?
    #   if ["AO"].include? current_user.roles.last
    #     if ["Aljon", "Adrian", "Diobert"].include? current_user.first_name
    #       @subheader_side_actions << {
    #         id: "btn-check",
    #         link: "#",
    #         class: "fa fa-check",
    #         text: "Check"
    #       }
    #     end
    #   end
    # end

    if @claim.for_approval?
      if ["MIS"].include? current_user.roles.last
        if ["Silvida", "NELLY"].include? current_user.first_name
          @subheader_side_actions << {
            id: "btn-approve",
            link: "#",
            class: "fa fa-check",
            text: "Approve"
          }
        end
      end

      if ["MIS", "AO"].include? current_user.roles.last
        if ["Aljon", "Jake", "Richard"].include? current_user.first_name
          @subheader_side_actions << {
            id: "btn-pending",
            link: "#",
            class: "fa fa-undo",
            text: "Revert Pending"
          }
        end
      end
    end

    if @claim.pending?
      if ["AO"].include? current_user.roles.last
        if @claim.note.nil?
          @subheader_side_actions << {
            id: "btn-note",
            link: "#",
            class: "fa fa-comments",
            text: "Add Note"
          }
        else
          @subheader_side_actions << {
            id: "btn-note",
            link: "#",
            class: "fa fa-edit",
            text:  "Edit Note"
          }
        end
      end
    end

    if @claim.for_posting?
      if ["MIS"].include? current_user.roles.last
        if ["Evelyn", "Analyn", "Maria Victoria"].include? current_user.first_name
          @subheader_side_actions << {
            id: "btn-post",
            link: "#",
            class: "fa fa-check",
            text: "Post"
          }
        end
      end
    end

    # FOR BLIP
    if @claim.claim_type == "BLIP"
      if @claim.pending? || @claim.for_approval? || @claim.for_posting? || @claim.approved?
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

        if @claim.pending? || @claim.for_approval?
          if ["MIS", "AO"].include? current_user.roles.last
            if @claim.pending? && !@claim.proceed_checking?
              @subheader_side_actions << {
                link: edit_claim_path(@claim),
                class: "fa fa-edit",
                text: "Edit"
              }
            end

            @subheader_side_actions << {
              link: claim_path(@claim),
              class: "fa fa-times",
              data: { method: :delete, confirm: "Are you sure?" },
              text: "Delete"
            }
          end
        end
      end
    end

    # FOR CLIP
    if @claim.claim_type == "CLIP"
      if @claim.pending? || @claim.for_approval? || @claim.for_posting? || @claim.approved?
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

        if @claim.pending? || @claim.for_approval?
          if ["MIS", "AO"].include? current_user.roles.last
            if @claim.pending? && !@claim.proceed_checking?
              @subheader_side_actions << {
                link: edit_claim_path(@claim),
                class: "fa fa-edit",
                text: "Edit"
              }
            end

            @subheader_side_actions << {
              link: claim_path(@claim),
              class: "fa fa-times",
              data: { method: :delete, confirm: "Are you sure?" },
              text: "Delete"
            }
          end
        end
      end
    end

    # FOR CALAMITY
    if @claim.claim_type == "CALAMITY ASSISTANCE"
      if @claim.pending? || @claim.for_approval? || @claim.for_posting? || @claim.approved?
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

        if @claim.pending? || @claim.for_approval?
          if ["MIS", "AO"].include? current_user.roles.last
            if @claim.pending? && !@claim.proceed_checking?
              @subheader_side_actions << {
                link: edit_claim_path(@claim),
                class: "fa fa-edit",
                text: "Edit"
              }
            end

            @subheader_side_actions << {
              link: claim_path(@claim),
              class: "fa fa-times",
              data: { method: :delete, confirm: "Are you sure?" },
              text: "Delete"
            }
          end
        end
      end
    end

    # FOR HIIP
    if @claim.claim_type == "HIIP"
      if @claim.pending? || @claim.for_approval? || @claim.for_posting? || @claim.approved?
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

        if @claim.pending? || @claim.for_approval?
          if ["MIS", "AO"].include? current_user.roles.last
            if @claim.pending? && !@claim.proceed_checking?
              @subheader_side_actions << {
                link: edit_claim_path(@claim),
                class: "fa fa-edit",
                text: "Edit"
              }
            end

            @subheader_side_actions << {
              link: claim_path(@claim),
              class: "fa fa-times",
              data: { method: :delete, confirm: "Are you sure?" },
              text: "Delete"
            }
          end
        end
      end
    end

    # FOR KALINGA
    if @claim.claim_type == "K-KALINGA"
      if @claim.pending? || @claim.for_approval? || @claim.for_posting? || @claim.approved?
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

        if @claim.pending? || @claim.for_approval?
          if ["MIS", "AO"].include? current_user.roles.last
            if @claim.pending? && !@claim.proceed_checking?
              @subheader_side_actions << {
                link: edit_claim_path(@claim),
                class: "fa fa-edit",
                text: "Edit"
              }
            end

            @subheader_side_actions << {
              link: claim_path(@claim),
              class: "fa fa-times",
              data: { method: :delete, confirm: "Are you sure?" },
              text: "Delete"
            }
          end
        end
      end
    end

    if @claim.claim_type == "K-BENTE"
      if @claim.pending? || @claim.for_approval? || @claim.for_posting? || @claim.approved?
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

        if @claim.pending? || @claim.for_approval?
          if ["MIS", "AO"].include? current_user.roles.last
            if @claim.pending? && !@claim.proceed_checking?
              @subheader_side_actions << {
                link: edit_claim_path(@claim),
                class: "fa fa-edit",
                text: "Edit"
              }
            end

            @subheader_side_actions << {
              link: claim_path(@claim),
              class: "fa fa-times",
              data: { method: :delete, confirm: "Are you sure?" },
              text: "Delete"
            }
          end
        end
      end
    end

    if @claim.claim_type == "KUYA JUN SCHOLARSHIP PROGRAM"
      if @claim.pending? || @claim.for_approval? || @claim.for_posting? || @claim.approved?
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

        if @claim.pending? || @claim.for_approval?
          if ["MIS", "AO"].include? current_user.roles.last
            if @claim.pending? && !@claim.proceed_checking?
              @subheader_side_actions << {
                link: edit_claim_path(@claim),
                class: "fa fa-edit",
                text: "Edit"
              }
            end

            @subheader_side_actions << {
              link: claim_path(@claim),
              class: "fa fa-times",
              data: { method: :delete, confirm: "Are you sure?" },
              text: "Delete"
            }
          end
        end
      end
    end

    if @claim.approved?
      if ["MIS"].include? current_user.roles.last
        if !@accounting_entry_data.nil?
          @subheader_side_actions << {
            id: "btn-print",
            class: "fa fa-print",
            link: "#",
            text: "Print Voucher",
            data: {
              id: "#{@accounting_entry.id}",
              cid: "#{@claim.id}",
            }
          }
        end
      end
    end

    @subheader_side_actions << {
      link: claims_path,
      class: "fa fa-arrow-left",
      text: "Back to Claims"
    }

    @payload = {
      id: @claim.id
    }
  end
end
