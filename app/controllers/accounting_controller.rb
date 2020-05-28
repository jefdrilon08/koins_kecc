class AccountingController < ApplicationController
  before_action :authenticate_user!

  def trial_balance
    @subheader_items = [
      {
        text: "Accounting"
      },
      {
        text: "Trial Balance"
      }
    ]

    @subheader_side_actions = [
    ]
  end

  def general_ledger_excel_url
  if params[:branch_id].present?
    branch = Branch.find(params[:branch_id])
  end
  if params[:accounting_code_ids].present?
    accounting_code_ids = params[:accounting_code_ids]
  end

  render json: { download_url: "#{general_ledger_excel_url_path(start_date: params[:start_date],end_date: params[:end_date], branch_id: branch.try(:id))}"}

  end
  def general_ledger_excel
        start_date          = params[:start_date].try(:to_date)
        end_date            = params[:end_date].try(:to_date)
        branch_id           = params[:branch_id]
        accounting_code_ids = params[:accounting_code_ids] || []
        branch              = Branch.where(id: branch_id).first
          config  = {
          start_date: start_date,
          end_date: end_date,
          branch: branch,
          accounting_code_ids: accounting_code_ids
        }
        data  = ::Accounting::GenerateGeneralLedgerExcel.new(
                                  config: config
                                ).execute!
         filename= "general_ledger.xlsx"
         data.serialize "#{Rails.root}/tmp/#{filename}"
        send_file "#{Rails.root}/tmp/#{filename}", filename: "#{filename}", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  
      end

  def general_ledger
    @subheader_items = [
      {
        text: "Accounting"
      },
      {
        text: "General Ledger"
      }
    ]

    @subheader_side_actions = []
  end

  def misc
    @records  = AccountingEntry.misc.where(branch_id: @branches.pluck(:id)).order("reference_number DESC, updated_at ASC")
    @accounting_funds = AccountingFund.all.order("name ASC")

    @start_date = params[:start_date] || Date.new(@current_date.year, @current_date.month, 1)
    @end_date   = params[:end_date] || Date.new(@current_date.year, @current_date.month, -1)
    @q          = params[:q]
    @statuses   = AccountingEntry::STATUSES

    if @q.present?
      @records  = @records.where(
                    "particular LIKE lower(?)",
                    "%#{@q.downcase}%"
                  )
    end

    if @start_date.present? && @end_date.present? && @start_date < @end_date
      @records  = @records.where("date_prepared >= ? AND date_prepared <= ?", @start_date, @end_date)
    end

    if params[:status].present?
      @status   = params[:status]
      @records  = @records.where(status: @status)
    end

    if params[:branch_id].present?
      @branch_id  = params[:branch_id]
      @records    = @records.where(branch_id: params[:branch_id])
    end

    @records  = @records.page(params[:page]).per(20)

    @subheader_items = [
      {
        text: "Accounting"
      },
      {
        text: "Books"
      },
      {
        text: "Miscellaeneous"
      }
    ]

    @subheader_side_actions = [
      {
        link: accounting_accounting_entry_form_path(book: "misc"),
        class: "fa fa-plus",
        text: "New Entry"
      }
    ]
  end

  def jvb
    @records  = AccountingEntry.jvb.where(branch_id: @branches.pluck(:id)).order("reference_number DESC, updated_at ASC")
    @accounting_funds = AccountingFund.all.order("name ASC")

    @start_date = params[:start_date] || Date.new(@current_date.year, @current_date.month, 1)
    @end_date   = params[:end_date] || Date.new(@current_date.year, @current_date.month, -1)
    @q          = params[:q]
    @statuses   = AccountingEntry::STATUSES

    if @q.present?
      @records  = @records.where(
                    "particular LIKE lower(?)",
                    "%#{@q.downcase}%"
                  )
    end


    if @start_date.present? && @end_date.present? && @start_date < @end_date
      @records  = @records.where("date_prepared >= ? AND date_prepared <= ?", @start_date, @end_date)
    end

    if params[:status].present?
      @status   = params[:status]
      @records  = @records.where(status: @status)
    end

    if params[:branch_id].present?
      @branch_id  = params[:branch_id]
      @records    = @records.where(branch_id: params[:branch_id])
    end

    if params[:accounting_fund_id].present?
      @accounting_fund_id  = params[:accounting_fund_id]
      @records    = @records.where(accounting_fund_id: @accounting_fund_id)
    end

    @records  = @records.page(params[:page]).per(20)

    @subheader_items = [
      {
        text: "Accounting"
      },
      {
        text: "Books"
      },
      {
        text: "General Journal"
      }
    ]

    @subheader_side_actions = [
      {
        link: accounting_accounting_entry_form_path(book: "jvb"),
        class: "fa fa-plus",
        text: "New Entry"
      }
    ]
  end

  def crb
    @records  = AccountingEntry.crb.where(branch_id: @branches.pluck(:id)).order("reference_number DESC, updated_at ASC")
    @accounting_funds = AccountingFund.all.order("name ASC")

    @start_date = params[:start_date] || Date.new(@current_date.year, @current_date.month, 1)
    @end_date   = params[:end_date] || Date.new(@current_date.year, @current_date.month, -1)
    @q          = params[:q]
    @statuses   = AccountingEntry::STATUSES

    if @q.present?
      @records  = @records.where(
                    "particular LIKE lower(?)",
                    "%#{@q.downcase}%"
                  )
    end

    if @start_date.present? && @end_date.present? && @start_date < @end_date
      @records  = @records.where("date_prepared >= ? AND date_prepared <= ?", @start_date, @end_date)
    end

    if params[:status].present?
      @status   = params[:status]
      @records  = @records.where(status: @status)
    end

    if params[:branch_id].present?
      @branch_id  = params[:branch_id]
      @records    = @records.where(branch_id: params[:branch_id])
    end

    if params[:accounting_fund_id].present?
      @accounting_fund_id  = params[:accounting_fund_id]
      @records    = @records.where(accounting_fund_id: @accounting_fund_id)
    end

    @records  = @records.page(params[:page]).per(20)

    @subheader_items = [
      {
        text: "Accounting"
      },
      {
        text: "Books"
      },
      {
        text: "Cash Receipts"
      }
    ]

    @subheader_side_actions = [
      {
        link: accounting_accounting_entry_form_path(book: "crb"),
        class: "fa fa-plus",
        text: "New Entry"
      }
    ]
  end

  def cdb
    @records  = AccountingEntry.cdb.where(branch_id: @branches.pluck(:id)).order("reference_number DESC, updated_at ASC")
    @accounting_funds = AccountingFund.all.order("name ASC")

    @start_date = params[:start_date] || Date.new(@current_date.year, @current_date.month, 1)
    @end_date   = params[:end_date] || Date.new(@current_date.year, @current_date.month, -1)
    @q          = params[:q]
    @statuses   = AccountingEntry::STATUSES

    if @q.present?
      @records  = @records.where(
                    "particular LIKE lower(?)",
                    "%#{@q.downcase}%"
                  )
    end

    if @start_date.present? && @end_date.present? && @start_date < @end_date
      @records  = @records.where("date_prepared >= ? AND date_prepared <= ?", @start_date, @end_date)
    end

    if params[:status].present?
      @status   = params[:status]
      @records  = @records.where(status: @status)
    end

    if params[:branch_id].present?
      @branch_id  = params[:branch_id]
      @records    = @records.where(branch_id: params[:branch_id])
    end

    if params[:accounting_fund_id].present?
      @accounting_fund_id  = params[:accounting_fund_id]
      @records    = @records.where(accounting_fund_id: @accounting_fund_id)
    end

    @records  = @records.page(params[:page]).per(20)

    @subheader_items = [
      {
        text: "Accounting"
      },
      {
        text: "Books"
      },
      {
        text: "Cash Disbursement"
      }
    ]

    @subheader_side_actions = [
      {
        link: accounting_accounting_entry_form_path(book: "cdb"),
        class: "fa fa-plus",
        text: "New Entry"
      }
    ]
  end

  def form
  end
end
