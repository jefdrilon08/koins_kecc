module RiskProfiles
  class BuildDailyMetrics
    def initialize(config:)
      @as_off = config[:test].to_date
      #raise @as_off.inspect

    end
    def execute!
        @get_month = @as_off.strftime("%m").to_i
        @get_year = @as_off.year

      
        
        @a = []
        Branch.all.each do |d|
          dbm = DailyBranchMetric.where("extract(year from as_of) = ? and extract(month from as_of) = ? and branch_id = ?", @get_year, @get_month, d.id).order(:as_of)
          if dbm.present?
            dbm_data = dbm.last.data
            #dbm.last.map{ |b| b}.each do |d|
              sum_member = dbm_data["loaners"]["total"].to_i + dbm_data["pure_savers"]["total"] + dbm_data["active_members"]["total"] + dbm_data["inactive_members"]["total"]
              
              par_rate = dbm.last.par.to_f * 100
              @a << {
                branch_id: dbm.last.branch_id ,
                total_mebers: sum_member,
                portfolio: dbm.last.portfolio,
                par_rate: par_rate.to_f.round(2),
                par_amount: dbm.last.par_amount

               }
            #end
          end
        end
        @a

    end
  end
end
