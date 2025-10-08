class BillingsController < ApplicationController
  before_action :authenticate_user!

  def index

    @billings = ReadOnlyBilling
      .select("id,si_number,or_number,ar_number,branch_id,center_id,collection_date,date_approved,status,total_expected_collections,total_collected")
      .includes(:center, :branch)
      .where(branch_id: @branches.pluck(:id))

    if params[:start_date].present? and params[:end_date].present?
      @billings = @billings.where("collection_date >= ? AND collection_date <= ?", params[:start_date], params[:end_date])
    end

    if params[:branch_id].present?
      @branch   = ReadOnlyBranch.find(params[:branch_id])
      @billings = @billings.where(branch_id: @branch.id)
    end

    if params[:center_id].present?
      @center   = ReadOnlyCenter.find(params[:center_id])
      @billings = @billings.where(center_id: @center.id)
    end

    if params[:status].present?
      @status = params[:status]
      @billings = @billings.where(status: @status)
    end

    if params[:si_number].present?
      @si_number = params[:si_number]
      @billings = @billings.where("LOWER(si_number) = ?", @si_number.downcase)
    end


    if params[:or_number].present?
      @or_number = params[:or_number]
      @billings = @billings.where(or_number: @or_number)
    end
    @data = @billing.try(:data).try(:with_indifferent_access)

    @billings = @billings.order("status DESC, collection_date DESC").page(params[:page]).per(LIST_PAGE_SIZE)

    @subheader_items = [
      { text: "Billings" }
    ]

    @subheader_side_actions = [
      { id: "btn-new-transaction", link: "#", class: "fa fa-plus", text: "New Transaction" }
    ]
  end

  def show
    @current_user = current_user

    @billing  = ReadOnlyBilling.find(params[:id])
    @billing_type = "regular"

    if @billing.processing?
      redirect_to billings_path
    else
      @data     = @billing.data.with_indifferent_access
      @current_date = ::Utils::GetCurrentDate.new(
                        config: {
                          branch: @billing.branch
                        }
                      ).execute!

#      @activity_logs  = ReadOnlyActivityLog.where(
#                          "data ->> 'billing_id' = ?",
#                          @billing.id
#                        ).order("created_at DESC")

      @subheader_items = [
        { is_link: true, path: billings_path, text: "Billings" },
        { text: "Billing #{@billing.id}" }
      ]

      @subheader_side_actions = []

      if @billing.pending?


        if helpers.is_mis_so_fm?
          @subheader_side_actions << {
            link: "#",
            class: "fa fa-print",
            id: "btn-save-billing",
            text: "Save"
          }

          @subheader_side_actions << {
            link: "#",
            class: "fa fa-download",
            id: "btn-termal",
            text: "Print Thermal Printer"
          }

          @subheader_side_actions << {
            id: "btn-zero-out",
            link: "#",
            class: "fa fa-times",
            text: "Zero Out"
          }


        end

      end

      if @billing.save?
        if @data[:save].present?

          if @data[:save]["id"] != current_user.id and helpers.is_mis_fm? || helpers.is_cm_mis?
            @subheader_side_actions << {
              link: "#",
              class: "fa fa-print",
              id: "btn-unsave-billing",
              text: "UnSave"
            }


          end

          if current_user.id and helpers.is_cm_mis?
            @subheader_side_actions << {
              id: "btn-check",
              link: "#",
              class: "fa fa-check",
              text: "Check"
            }
          elsif current_user.id and helpers.is_mis_fm?
            @subheader_side_actions << {
                id: "btn-check",
                link: "#",
                class: "fa fa-check",
                text: "Check"
              }
          end
        else
          if helpers.is_mis_fm?
            @subheader_side_actions << {
                id: "btn-check",
                link: "#",
                class: "fa fa-check",
                text: "Check"
              }
            @subheader_side_actions << {
              link: "#",
              class: "fa fa-print",
              id: "btn-unsave-billing",
              text: "UnSave"
            }
          end
        end

      end

      if @billing.checked?
        if helpers.sbk_bk_mis_user
          @subheader_side_actions << {
            id: "btn-uncheck",
            link: "#",
            class: "fa fa-check",
            text: "Uncheck"
          }
          @subheader_side_actions << {
            id: "btn-approve",
            link: "#",
            class: "fa fa-check",
            text: "Approve"
          }
        end
      end


      if @billing.approved?
          if helpers.sbk_bk_mis_user
            @subheader_side_actions << {
            link: "#",
            class: "fa fa-print",
            id: "btn-print-pdf",
            text: "Print PDF"
          }
          end

          # "Print Thermal Printer" for approved billings
        @subheader_side_actions << {
          link: "#",
          class: "fa fa-download",
          id: "btn-termal",
          text: "Print Thermal Printer"
        }
      end

      @subheader_side_actions << {
        link: "#",
        class: "fa fa-print",
        id: "btn-print-wp",
        text: "Print Withdraw Payment"
      }

      @subheader_side_actions << {
        link: "#",
        class: "fa fa-print",
        id: "btn-print",
        text: "Print Billing"
      }

      @subheader_side_actions << {
        link: "#",
        class: "fa fa-download",
        id: "btn-excel",
        text: "Download Excel"
      }


      @payload = {
        id: @billing.id
      }
    end
      if @billing.pending?
        if helpers.is_mis_fm?
          @subheader_side_actions << {
            link: billing_path(@billing.id),
            class: "fa fa-times",
            data: { method: :delete, confirm: "Are you sure?" },
            text: "Delete"
          }

        end
      end
  end

  def destroy
    @billing  = Billing.find(params[:id])

    if @billing.pending?
      @billing.destroy!

      redirect_to billings_path
    elsif @billing.status == "error"
      @billing.destroy!

      redirect_to billings_path
    else
      redirect_to billing_path(@billing)
    end
  end

  def excel
    render json: {download_url: "#{billing_download_excel_path(billing: params[:id])}"}
  end

  def billing_excel

    billing_excel = ::Billings::BillingDownloadExcel.new(billing: params[:billing]).execute!
    filename = "billing.xlsx"
    billing_excel.serialize "#{Rails.root}/tmp/#{filename}"
    send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

  end

end
