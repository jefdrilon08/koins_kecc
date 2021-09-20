module Reports
  class GenerateMigs
    def initialize
      @data = {}
      @watchlist = DataStore.find("19369f65-2582-47f8-8333-608d1713111e").data.with_indifferent_access["records"].select{ |o| o[:num_days_par] > 0  }
    end
    def execute!

      @watchlist.each do |w|
        
      end
    end
  end
end
