module AllowanceLosses
  class GenerateAllowanceLosses
    attr_reader :ids, :sector_names, :cluster_names, :sato_names, :par_months, :par_years, :par_greater_years, :principal_balances

    def initialize(data:)
      @data = data
      @results = []
      @ids = []
      @sector_names = []
      @cluster_names = []
      @sato_names = []
      @par_months = []
      @par_years = []
      @par_greater_years = []
      @principal_balances = []
    end

    def execute!
      Array.wrap(@data).each do |datum|
        processed_datum = process(datum)
        @results << processed_datum
        @ids << datum.id

        datum.data['records'].each do |record|
          sector_name = record['sector_name']
          @sector_names << sector_name if sector_name.present?

          record['cluster'].each do |cluster|
            cluster_name = cluster['cluster_name']
            @cluster_names << cluster_name if cluster_name.present?

            cluster['sato'].each do |sato|
              sato_name = sato['sato_name']
              @sato_names << sato_name if sato_name.present?
              par_month = sato['par_month']
              @par_months << par_month if par_month.present?
              par_year = sato['par_year']
              @par_years << par_year if par_year.present?
              par_greater_year = sato['par_greater_year']
              @par_greater_years << par_greater_year if par_greater_year.present?
              principal_balance = sato['principal_balance']
              @principal_balances << principal_balance if principal_balance.present?
            end
          end
        end
      end

      @results
    end

    private

    def process(datum)
      datum.attributes.merge(processed: true)
    end
  end
end
