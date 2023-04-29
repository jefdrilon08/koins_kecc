module DataStores
  class SaveProjectTypeSummary
    
    def initialize(config:)
      @config =  config
      @data_date = Date.today
      @branch = Branch.find(@config[:branch_id])
      @user = @config[:user]
    
      @meta = {
        branch_id: @branch.id,
        created_by: @user.full_name,
        date_created: @data_date,
        data_store_type: "PROJECT_TYPE_SUMMARY"


      }
    end
    
    def execute!

    pDetails = ::DataStores::GenerateProjectTypeSummary.new(branch_id: @branch.id).execute!
    
    @data = DataStore.create!( meta: @meta, data: pDetails, status: "pending" )

    @data.save!

    @data

  
    end

  end
end
