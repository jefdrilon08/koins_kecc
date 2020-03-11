class DataStoreController < ApplicationController
  before_action :authenticate_user!

  def index
    @records = list_query(branch_data_stores)
  end

  def show
    @record = branch_data_stores.find_by(id: params[:id])

    if !@record || @record.processing?
      # XXX: Flashes aren't being used yet
      #
      # flash[:notice] = "#{data_store_scope.humanize} ##{@record.id} not found."
      redirect_to [:data_stores, data_store_scope]
    end
  end

  def destroy
    @record = branch_data_stores.find(id: params[:id])

    if !@record.processing?
      @record.destroy!
      flash[:danger] = "#{data_store_scope.humanize} ##{@record.id} deleted."
    else
      flash[:danger] = "#{data_store_scope.humanize} ##{@record.id} still processing."
    end

    redirect_to [:data_stores, data_store_scope]
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
    DataStore.send(data_store_scope)
  end

  def list_query_config
    {
      "accounting_entries_summaries" => { order: "CAST(meta->>'end_date' AS date) DESC",   meta: %w[branch_name book start_date end_date], data: %w[] },
      "branch_repayment_reports"     => { order: "CAST(meta->>'as_of' AS date) DESC",      meta: %w[branch_name as_of], data: %w[] },
      "branch_resignations"          => { order: "CAST(meta->>'as_of' AS date) DESC",      meta: %w[branch_name start_date end_date], data: %w[] },
      "icpr"                         => { order: "meta->>'year' DESC",                     meta: %w[branch_name year], data: %w[] },
      "manual_aging"                 => { order: "CAST(meta->>'as_of' AS date) DESC",      meta: %w[branch_name as_of], data: %w[] },
      "member_counts"                => { order: "CAST(meta->>'as_of' AS date) DESC",      meta: %w[branch_name as_of], data: %w[] },
      "monthly_incentives"           => { order: "CAST(meta->>'as_of' AS date) DESC",      meta: %w[branch_name as_of], data: %w[] },
      "monthly_new_and_resigned"     => { order: "CAST(meta->>'as_of' AS date) DESC",      meta: %w[branch_name as_of], data: %w[num_new num_resigned] },
      "patronage_refund"             => { order: "CAST(meta->>'as_of' AS date) DESC",      meta: %w[branch_name start_date end_date equity_rate], data: %w[] },
      "personal_funds"               => { order: "CAST(meta->>'as_of' AS date) DESC",      meta: %w[branch_name as_of], data: %w[] },
      "repayment_rates"              => { order: "CAST(meta->>'as_of' AS date) DESC",      meta: %w[branch_name as_of], data: %w[] },
      "soa_expenses"                 => { order: "CAST(meta->>'start_date' AS date) DESC", meta: %w[branch_name start_date end_date], data: %w[] },
      "soa_funds"                    => { order: "CAST(meta->>'end_date' AS date) DESC",   meta: %w[branch_name start_date end_date], data: %w[] },
      "soa_loans"                    => { order: "CAST(meta->>'end_date' AS date) DESC",   meta: %w[branch_name start_date end_date], data: %w[] },
      "watchlists"                   => { order: "CAST(meta->>'as_of' AS date) DESC",      meta: %w[branch_name as_of], data: %w[] },
      "x_weeks_to_pay"               => { order: "CAST(meta->>'as_of' AS date) DESC",      meta: %w[branch_name as_of x], data: %w[date_until] },
    }
  end

  def list_query(scope)
    config = list_query_config.fetch(data_store_scope)
    meta_fields = config.fetch(:meta).map { |f| "meta->>'#{f}' as #{f}" }
    data_fields = config.fetch(:data).map { |f| "data->>'#{f}' as #{f}" }
    order_field = config.fetch(:order)

    scope
      .select("id, status, created_at, updated_at, #{(meta_fields + data_fields).join(", ")}")
      .where("meta->>'branch_id' IN (?)", @branches.pluck(:id))
      .order(order_field)
      .page(params[:page])
      .per(LIST_PAGE_SIZE)
  end
end
