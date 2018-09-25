# Super class for insert_* operations
module Loaders
  class InsertFromFile
    def initialize(params:)
      @params     = params
      @root       = @params[:root]
      @filename   = @params[:filename]
      @full_path  = "#{@root}/#{@filename}"
      @data       = JSON.parse(File.read(@full_path)).deep_symbolize_keys!
    end
  end
end
