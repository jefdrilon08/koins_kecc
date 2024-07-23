module Api
  module V1
    module DataStores
      class WrittenOffReportController < ApiController

        def fetch
          record = DataStore.find(params[:data_store_id])
          name_to_match = params[:name]
        
          if record.blank?
            render json: { errors: { key: "id", message: "not found" }, full_messages: ["not found"] }, status: 400
          else
            records = record.data.with_indifferent_access[:records]
            
            matching_records = records.select do |re|
              full_name = re['members']['full_name']
              name_parts = full_name.split(',').map(&:strip)
        
              last_name = name_parts[0]
              first_name = name_parts[1]
              middle_name = name_parts[2] || '' 
        
              [last_name, first_name, middle_name].include?(name_to_match)
            end
        
            if matching_records.any?
              puts "hahahashdahwda"+matching_records.inspect
            else
              render json: { errors: { key: "name", message: "not found" }, full_messages: ["Name not found"] }, status: 404
            end
          end
        end
        



        def generate
          branch_id = params[:branch_id]
          data_store_type = "WRITTEN_OFF_REPORT"
          today_date = Date.today
          branch_name = Branch.find(branch_id).name

          record = DataStore.create!(
            meta: {
              data_store_type: data_store_type,
              date_generated: today_date,
              branch_id: branch_id,
              branch_name: branch_name
            },
            data: {
              records: [],
            }
          )

          args = {
            data_store_id: record.id,
            branch_id: branch_id
          }

          ProcessWrittenOffReport.perform_later(args)

          render json: { message: "Processing written off report." }
        end
      end
    end
  end
end
