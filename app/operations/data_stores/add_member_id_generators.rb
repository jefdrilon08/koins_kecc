module DataStores
  class AddMemberIdGenerators
    def initialize(config:)
      @config = config
      @data_store = DataStore.find(@config[:data_store_id])
      @center = Center.find(@config[:center_id])
      @member = Member.find(@config[:member_id])
      @member_type = @config[:member_type]
      
    end
    def execute!
    end
  end
end
