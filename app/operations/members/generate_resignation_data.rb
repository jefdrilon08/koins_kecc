module Members
  class GenerateResignationData
    def initialize(config:)
      @config = config

      @branch     = @config[:branch]
      @start_date = @config[:start_date].try(:to_date)
      @end_date   = @config[:end_date].try(:to_date)

      @data = {
        start_date: @start_date,
        end_date: @end_date,
        branch: {
          id: @branch.id,
          name: @branch.name
        },
        automatic: [],
        voluntary: [],
        involuntary: []
      }
    end

    def execute!
      @data[:automatic]   = build_records!("automatic")
      @data[:voluntary]   = build_records!("voluntary")
      @data[:involuntary] = build_records!("involuntary")
    end

    private

    def build_records!(type)
      sql     = "SELECT * FROM members m WHERE EXISTS (SELECT 1 FROM json_array_elements(m.data->'resignation_records') elem WHERE DATE(elem ->> 'date_resigned') >= '#{@start_date}' AND DATE(elem ->> 'date_resigned') <= '#{@end_date}' AND elem -> 'member_resignation_type' ->> 'name' = '#{type}')"

      results = ActiveRecord::Base.connection.execute(sql)

      results.to_a.map{ |o|
        {
          id: o["id"]
        }
      }
    end
  end
end
