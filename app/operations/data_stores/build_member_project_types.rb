module DataStores
  class BuildMemberProjectTypes
    def initialize(config:)
      
      @branch_id = config[:branch]
      @center_id = config[:center]
      @branch_name = Branch.find(@branch_id)
      @center_name = Center.find(@center_id)

      @meta = {
        branch_id: @branch_id,
        branch_name:  @branch_name.name,
        center_id: @center_id,
        center_name: @center_name.name,
        data_store_type: "PROJECT TYPE"
      }

    end
    def execute!
      
      @data = DataStore.create!( meta: @meta, status: "pending"  )

      @data.save!

      @data
    end
  end
end
