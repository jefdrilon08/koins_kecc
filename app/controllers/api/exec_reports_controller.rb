module Api
  class ExecReportsController < Api::FrontController
    def psr_query
      current_date  = Date.today
      current_month = current_date.month
      current_year  = current_date.year

      area    = Area.find_by_id(params[:area_id])
      cluster = Cluster.find_by_id(params[:cluster_id])
      branch  = Branch.find_by_id(params[:branch_id])
      month   = params[:month].try(:to_i) || current_month
      year    = params[:year].try(:to_i) || current_year

      cmd = ::ExecReports::BuildPsrQuery.new(
        area:     area,
        cluster:  cluster,
        branch:   branch,
        month:    month,
        year:     year
      )

      cmd.execute!

      render json: { data: cmd.data }
    end
  end
end
