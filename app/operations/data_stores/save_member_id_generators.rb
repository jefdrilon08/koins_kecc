module DataStores
  class SaveMemberIdGenerators
    def initialize(config:)
      @config =  config
      @data_date = Date.today
      @branch = Branch.find(@config[:branch_id])
      @user = @config[:user]
      @build_refference = "KCOOP_#{@branch.short_name}_ID_#{@data_date.strftime("%y%d%m")}"
    
      @meta = {
        branch_id: @branch.id,
        created_by: @user.full_name,
        date_created: @data_date,
        refference_number: @build_refference,
        data_store_type: "GENERATED_ID"


      }

    
    end
    def execute!
      @data = DataStore.create!( meta: @meta, data: [], status: "pending" )
      @data    
    end
  end
end
