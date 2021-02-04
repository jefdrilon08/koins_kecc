class DailyBranchMetricsController < ApplicationController
  before_action :authenticate_user!

  def show
    @daily_branch_metric = ReadOnlyDailyBranchMetric.find(params[:id])

    @subheader_items = [
      {
        is_link: true,
        path: "/daily_branch_metrics",
        text: "Daily Branch Metrics"
      },
      {
        text: "#{@daily_branch_metric.branch} - #{@daily_branch_metric.as_of.strftime("%B %d, %Y")}"
      }
    ]

    @subheader_side_actions = [
    ]

    @payload = {
      "id": @daily_branch_metric.id
    }
  end

  def index
    @daily_branch_metrics = ReadOnlyDailyBranchMetric
                              .includes(:branch)
                              .select("*")
                              .where(branch_id: @branches.pluck(:id))                      

    @branch     = ReadOnlyBranch.find_by_id(params[:branch_id])
    @start_date = params[:start_date].try(:to_date) || @current_date
    @end_date   = params[:end_date].try(:to_date) || @current_date

    if @branch.present?
      @daily_branch_metrics = @daily_branch_metrics.where(branch_id: @branch.id)
    end

    if @start_date.present? and @end_date.present? and @start_date <= @end_date
      @daily_branch_metrics = @daily_branch_metrics.where(
                                "as_of >= ? AND as_of <= ?",
                                @start_date,
                                @end_date
                              )
    end

    @daily_branch_metrics = @daily_branch_metrics
                              .order("as_of DESC")
                              .page(params[:page])
                              .per(LIST_PAGE_SIZE)

    @subheader_items = [
      { text: "Daily Branch Metrics" },
    ]

    @subheader_side_actions = [
      { id: "btn-new", link: "#", class: "fa fa-plus", text: "New Record" }
    ]

    @payload = {
      urlSave: "/api/v2/branches/save_daily_branch_metric",
      userId: current_user.id,
      xKoinsAppAuthSecret: ENV['KOINS_APP_AUTH_SECRET']
    }
  end
end
