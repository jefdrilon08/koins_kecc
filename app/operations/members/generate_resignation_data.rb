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
        records: []
      }
    end

    def execute!

      Settings.member_resignation_types.each do |setting|
        record  = {
          name: setting.name,
          particulars: []
        }

        particulars = setting.particulars

        particulars.each do |p|
          record_particular = {
            code: p.code,
            name: p.name,
            records: []
          }
          
          record_particular[:records] = build_records!(setting.name, p.code)
          record[:particulars] << record_particular
        end


       
        @data[:records] << record
      end

      @data
    end

    private

    def build_records!(type, code)
      sql     = "SELECT * FROM members m WHERE m.branch_id = '#{@branch.id}' and m.date_resigned >= '#{@start_date}'  and m.date_resigned <= '#{@end_date}' AND EXISTS (SELECT 1 FROM json_array_elements(m.data->'resignation_records') elem WHERE DATE(elem ->> 'date_resigned') >= '#{@start_date}' AND DATE(elem ->> 'date_resigned') <= '#{@end_date}' AND elem -> 'member_resignation_type' ->> 'name' = '#{type}' AND elem -> 'member_resignation_type' -> 'particular' ->> 'code' = '#{code}')"

      results = ActiveRecord::Base.connection.execute(sql)
      
      results.to_a.map{ |o|
        {

          id: o["id"],
          identification_number: o["identification_number"],
          first_name: o["first_name"],
          middle_name: o["middle_name"],
          last_name: o["last_name"],
          data: JSON.parse(o["data"])
        }
      }

    end
  end
end
