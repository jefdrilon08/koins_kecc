module DataStores
  class GenerateAllowanceComputationReport
  
    def initialize(config:)
      @config       = config
      @as_of        = @config[:as_of]
      @data_store   = DataStore.find(@config[:data_store_id])
      @data         = @data_store.data.with_indifferent_access
      @records      = @data[:records]
      @per_sato     = AdministrationBranchClosingRecord.where(closing_date: @as_of, record_type: 'REPAYMENT_RATES')
      @sector       = Area.where.not(id: "06a78557-bbc4-491a-bef9-b6c2e6938671").order(:name)
    end

    def execute!
      add_sector!
      add_cluster!
      @records.each do |rec_sec|
        rec_sec[:cluster].each do |cl|
          sato = Branch.where(cluster_id: cl[:cluster_id])
          sato.each do |sat|
            closing_record = AdministrationBranchClosingRecord.where(closing_date: @as_of, record_type: 'REPAYMENT_RATES' , branch_id: sat.id).last
            rr  = DataStore.find(closing_record.data_store_id)
            rr_data          = rr.data.with_indifferent_access
            record           = rr_data['records']
            rr_month         = record.select{|r| r['num_days_par'] >=1 and r['num_days_par'] <= 30}
            par_month        = rr_month.map{|r| r['overall_principal_balance']}.sum
            rr_year          = record.select{|r| r['num_days_par'] >=31 and r['num_days_par'] <= 365}
            par_year         = rr_year.map{|r| r['overall_principal_balance']}.sum
            rr_greater_year  = record.select{|r| r['num_days_par'] >= 366}
            par_greater_year = rr_greater_year.map{|r| r['overall_principal_balance']}.sum
 
            cl[:sato] << {
              sato_name: sat.name,
              sato_id: sat.id,
              closing_record_id: closing_record.id,
              rr_id: closing_record.data_store_id,
              par_month: par_month,
              par_year: par_year,
              par_greater_year: par_greater_year,
              principal_balance: rr_data['total_overall_principal_balance']
            }
          end
        end
      end
      #per_sato!
      #totals!
      @data_store.update(data: @data)
    end

    def add_sector!
      @sector.each do |sec|
        @data[:records] << {
          sector_name: sec.name,
          sector_id: sec.id,
          cluster: []
        }
      end 
    end

    def add_cluster!
      @data[:records].each do |rec|
        cluster = Cluster.where(area_id: rec[:sector_id])
        cluster.each do |clust|
          rec[:cluster] << {
            cluster_id: clust.id,
            cluster_name: clust.name,
            sato: []
          }
        end
      end
    end

    def per_sato!
      @per_sato.each do |ps|
        rr               = DataStore.find(ps['data_store_id'])
        rr_data          = rr.data.with_indifferent_access
        cluster_id       = ReadOnlyBranch.find(rr.meta["branch_id"]).cluster_id
        area_id          = Cluster.find(cluster_id).area_id
        record           = rr_data['records']
        rr_month         = record.select{|r| r['num_days_par'] >=1 and r['num_days_par'] <= 30}
        par_month        = rr_month.map{|r| r['overall_principal_balance']}.sum
        rr_year          = record.select{|r| r['num_days_par'] >=31 and r['num_days_par'] <= 365}
        par_year         = rr_year.map{|r| r['overall_principal_balance']}.sum
        rr_greater_year  = record.select{|r| r['num_days_par'] >= 366}
        par_greater_year = rr_greater_year.map{|r| r['overall_principal_balance']}.sum
        @data[:sato] << { 
          data_store_id: ps['data_store_id'],
          sato_name: rr.meta["branch_name"],
          sato_id: rr.meta["branch_id"] ,
          cluster_id: cluster_id,
          area_id: area_id,
          par_month: par_month,
          par_year: par_year,
          par_greater_year: par_greater_year,
          principal_balance: rr_data['total_overall_principal_balance']
        }
      end
    end

    def totals!
      totals = @data[:totals]
      sato = @data[:sato]
      totals[:total_par_month] = sato.map { |st| st[:par_month] }.sum
      totals[:total_par_year] = sato.map { |st| st[:par_year] }.sum
      totals[:total_par_greater] = sato.map { |st| st[:par_greater_year] }.sum
      totals[:total_principal_balance] = sato.map { |st| st[:principal_balance] }.sum
      totals[:total_par] = {
        total_par_month: totals[:total_par_month],
        total_par_year: totals[:total_par_year],
        total_par_greater: totals[:total_par_greater]
      }.values.sum
      totals[:portfolio_less_par] = totals[:total_principal_balance] - totals[:total_par]
    end
  
  end
end
 
