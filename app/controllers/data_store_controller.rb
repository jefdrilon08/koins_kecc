class DataStoreController < ApplicationController
  before_action :authenticate_user!

  def index
    @records      = list_query(branch_data_stores)
    @start_date   = params[:start_date]
    @end_date     = params[:end_date]
    @l_start_date = params[:l_start_date]
    @l_end_date   = params[:l_end_date]
    @br_id        = Branch.where(id: params[:branch_id]).first
    @book         = params[:book]
    @book_s_date  = params[:book_start_date]
    @book_e_date  = params[:book_end_date]
    @status       = params[:status]

    if @start_date.present?
      @records = @records.where(
                  "as_of >= ?" , @start_date
                  )

    end

    if @end_date.present?
      @records = @records.where(
                  "as_of <= ?" , @end_date
                  )
    end

    if @l_start_date.present? and @l_end_date.present?
      @records  = @records.where(
                    "updated_at >= ? and updated_at <= ?",
                    @l_start_date,
                    @l_end_date
                  )
    end

    if @br_id.present?
      @records = @records.where(
                  "meta ->> 'branch_id' = ?" , @br_id
                  )
    end

    #for books
    if @book.present?
      @records = @records.where(
                  "meta ->> 'book' = ?" , @book
                  )
    end


    if @book_s_date.present?
      @records = @records.where(
                  "meta ->> 'start_date' = ?" , @book_s_date
                  )
    end

    if @book_e_date.present?
      @records = @records.where(
                  "meta ->> 'end_date' = ?" , @book_e_date
                  )
    end

    if @status.present?
      @records  = @records.where(
                    status: @status
                  )
    end
  end

  def show
    @record = branch_data_stores.find_by(id: params[:id])
    if !@record || @record.processing?
      # XXX: Flashes aren't being used yet
      #
      # flash[:notice] = "#{data_store_scope.humanize} ##{@record.id} not found."
      redirect_to [:data_stores, data_store_scope.to_sym]
    end
  end

  def destroy
    @record = DataStore.find(params[:id])

    if !@record.processing? || !@record_summary.processing?
      @record.destroy!
      flash[:danger] = "#{data_store_scope.humanize} ##{@record.id} deleted."
    else
      flash[:danger] = "#{data_store_scope.humanize} ##{@record.id} still processing."
    end

    redirect_to [:data_stores, data_store_scope.to_sym]
  end

  private

  # Derive scope from controller name.
  #
  # "DataStores::RepaymentRatesController"
  # => "repayment_rates"
  # ```
  def data_store_scope
    self.class.name.split("::").last.split("Controller").first.underscore
  end

  def branch_data_stores
    ReadOnlyDataStore.send(data_store_scope)
  end

  def list_query_config
    {
      "accounting_entries_summaries"            => { order: "end_date DESC",   meta: %w[branch_name book start_date end_date], data: %w[] },
      "branch_repayment_reports"                => { order: "as_of DESC",      meta: %w[branch_name as_of], data: %w[] },
      "branch_resignations"                     => { order: "as_of DESC",      meta: %w[branch_name start_date end_date], data: %w[] },
      "icpr"                                    => { order: "updated_at DESC", meta: %w[branch_name year], data: %w[] },
      "manual_aging"                            => { order: "as_of DESC",      meta: %w[branch_name as_of], data: %w[] },
      "member_counts"                           => { order: "as_of DESC",      meta: %w[branch_name as_of], data: %w[] },
      "insurance_member_counts"                 => { order: "as_of DESC",      meta: %w[branch_name as_of], data: %w[] },
      "claims_counts"                           => { order: "as_of DESC",      meta: %w[branch_name as_of], data: %w[] },
      "uploaded_documents_counts"               => { order: "as_of DESC",      meta: %w[branch_name as_of], data: %w[] },
      "monthly_incentives"                      => { order: "as_of DESC",      meta: %w[branch_name as_of], data: %w[] },
      "monthly_new_and_resigned"                => { order: "as_of DESC",      meta: %w[branch_name as_of], data: %w[num_new num_resigned] },
      "patronage_refund"                        => { order: "updated_at DESC",      meta: %w[branch_name start_date end_date equity_rate], data: %w[] },
      "personal_funds"                          => { order: "as_of DESC",      meta: %w[branch_name as_of], data: %w[] },
      "repayment_rates"                         => { order: "as_of DESC",      meta: %w[branch_name as_of], data: %w[] },
      "soa_expenses"                            => { order: "start_date DESC", meta: %w[branch_name start_date end_date], data: %w[] },
      "soa_funds"                               => { order: "end_date DESC",   meta: %w[branch_name start_date end_date], data: %w[] },
      "soa_loans"                               => { order: "end_date DESC",   meta: %w[branch_name start_date end_date], data: %w[] },
      "watchlists"                              => { order: "as_of DESC",      meta: %w[branch_name as_of], data: %w[] },
      "x_weeks_to_pay"                          => { order: "as_of DESC",      meta: %w[branch_name as_of x], data: %w[date_until] },
      "members_in_good_standing"                => { order: "as_of DESC",      meta: %w[branch_name start_date end_date], data: %w[]},
      "for_writeoff"                            => { order: "created_at DESC",      meta: %w[branch_name start_date end_date], data: %w[]},
      "billing_for_writeoff"                    => { order: "as_of DESC",      meta: %w[branch_name start_date end_date], data: %w[]},
      "insurance_personal_funds"                => { order: "as_of DESC",      meta: %w[branch_name as_of], data: %w[] },
      "billing_for_writeoff_collections"        => { order: "as_of DESC",      meta: %w[branch_name start_date end_date], data: %w[]},
      "additional_share"                        => { order: "as_of DESC",      meta: %w[branch_name start_date end_date], data: %w[]},
      "mbs_transfer"                            => { order: "as_of DESC",      meta: %w[branch_name start_date end_date], data: %w[]},
      "involuntary_members"                     => {order: "as_of DESC", meta: %w[branch_name as_of],data: %[]},
      "assets_liabilities"                      => {order: "created_at DESC", meta: %w[start_date, end_date],data: %w[] },

      "branch_cash_flow"                        => {order: "as_of DESC", meta: %w[branch_name as_of],data: %w[] },

      "member_quarterly_reports"                => { order: "as_of DESC", data: %w[] },
      "share_capital_involuntary"               => {order: "as_of DESC",data: %w[] },
      "billing_for_involuntary"                 => {order: "created_at DESC",      meta: %w[branch_name], data: %w[]},
      "member_per_center_counts"                => { order: "as_of DESC",      meta: %w[branch_name as_of], data: %w[] },
      "allowance_computation_report"            => { order: "as_of DESC",      meta: %w[branch_name as_of], data: %w[] },
      "kbente_summary"                          => { order: "as_of DESC",      meta: %w[branch_name as_of], data: %w[] },
      "kkalinga_summary"                        => { order: "as_of DESC",      meta: %w[branch_name as_of], data: %w[] },
      "kok_summary"                        => { order: "as_of DESC",      meta: %w[branch_name as_of], data: %w[] }
    }
  end

  def list_query(scope)
    config = list_query_config.fetch(data_store_scope)
    order_field = config.fetch(:order)

    scope
      .select("id, meta, status, created_at, updated_at, start_date, end_date, as_of")
      .where("meta->>'branch_id' IN (?)", @branches.pluck(:id))
      .order(order_field)
      .page(params[:page])
      .per(LIST_PAGE_SIZE)
  end
end
