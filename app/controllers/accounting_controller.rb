class AccountingController < ApplicationController
  before_action :authenticate_user!

  def trial_balance
  end

  def general_ledger
  end

  def misc
    @records  = AccountingEntry.misc.where(branch_id: @branches.pluck(:id)).order("reference_number DESC, updated_at ASC")

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
  end

  def jvb
    @records  = AccountingEntry.jvb.where(branch_id: @branches.pluck(:id)).order("reference_number DESC, updated_at ASC")

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
  end

  def crb
    @records  = AccountingEntry.crb.where(branch_id: @branches.pluck(:id)).order("reference_number DESC, updated_at ASC")

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
  end

  def cdb
    @records  = AccountingEntry.cdb.where(branch_id: @branches.pluck(:id)).order("reference_number DESC, updated_at ASC")

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
  end

  def form
  end
end
