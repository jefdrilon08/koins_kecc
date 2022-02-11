module DataStores
  class AddMemberIdGenerators
    def initialize(config:)
      @config = config
    
      @data_store = DataStore.find(@config[:data_store_id])
      @data_store_data = @data_store.data
      @member = Member.find(@config[:member_id])
      @id_type = @config[:id_type]
      @contact_person = @config[:contact_person]
      @contact_person_number = @config[:contact_person_number]
      @civil_status = @member.civil_status  
      
      @address = @member.data.with_indifferent_access[:address]
      @addressVal  = [@address[:street],@address[:district],@address[:city],@address[:province],@address[:region]]
      

    end
    def execute!
      if @civil_status == "Single" || @civil_status == "May Kinakasama" || @civil_status == "Hiwalay" || @civil_status == "separated" || @civil_status == "single"
        @civil_status_for_id = "Single"
      elsif @civil_status == "Kasal" || @civil_status == "married"
        @civil_status_for_id = "Married"
      elsif @civil_status == "Biyudo/a" || @civil_status == "widowed"
        @civil_status_for_id = "Widow"
      end


      @member_details = { 
                          id: @member.id, 
                          first_name: @member.first_name,
                          last_name: @member.last_name,
                          middle_name: @member.middle_name,
                          member_id_number: @member.identification_number,
                          center: @member.center.name,
                          birtdate: @member.date_of_birth,
                          id_type: @id_type ,
                          civil_status: @civil_status_for_id,
                          contact_person: @contact_person,
                          contact_person_number: @contact_person_number,
                          address: @addressVal.join(', ')
                        }
      @data_store_data << @member_details
      @data_store.update(data: @data_store_data)
    end
  end
end
