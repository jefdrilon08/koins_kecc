module Loaders
  class InsertAccountingCodesFromFile
    def initialize(params:)
      @params     = params
      @root       = @params[:root]
      @filename   = @params[:filename]
      @full_path  = "#{@root}/#{@filename}"
      @data       = JSON.parse(File.read(@full_path)).deep_symbolize_keys!
    end

    def execute!
      AccountingCode.transaction do
        columns = [
          :id, 
          :name, 
          :code, 
          :category, 
          :data
        ]

        AccountingCode.import columns, @data[:accounting_codes]
      end
    end
  end
end
