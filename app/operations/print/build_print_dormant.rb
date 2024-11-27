module Print
  class BuildPrintDormant
    include ActionView::Helpers::NumberHelper

    def initialize(params)
      # Extract the DataStore object from the params hash
      @drmt = params[:drmt]

      # Safely access `meta` and `data` attributes
      @meta = @drmt.meta || {}
      @data = @drmt.data || {}

      # Extract information from meta
      @branch_name = @meta["branch_name"] || "Unknown Branch"
      @drmt_as_of = @meta["as_of"] || "Unknown Date"
    end

    def execute!
      @data_output = {
        branch_name: @branch_name,
        as_of: @drmt_as_of,
        records: build_records,
        header: build_header 
      }
      @data_output
    end

    def build_records
      records = @data["record"] || []
      records.map do |record|
        {
          full_name: record["full_name"] || "Unknown",
          center_name: record["center_name"] || "N/A",
          member_status: record["member_status"] || "Unknown",
          balance: record["balance"].to_f,
          dormant_fee: record["dormant_fee"].to_f
        }
      end.sort_by { |record| record[:center_name] || "" }
    end
  
    def build_header
      headers = @data["header"] || []
      headers.map do |header|
        {
          total_amount: header["total_amount"].to_f,
          total_payment: header["total_payment"].to_f
        }
      end
    end

  end
end
