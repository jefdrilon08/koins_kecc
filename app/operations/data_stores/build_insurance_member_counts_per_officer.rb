module DataStores
  class BuildInsuranceMemberCountsPerOfficer
    def initialize(mc_data:)
      @mc_data  = mc_data

      @data = {
        officers: []
      }

      @officers = []

      @mc_data[:counts][:active_members][:members].each do |m|
        @officers << m[:officer]
      end

      @officers = @officers.uniq
    end

    def execute!
      @officers.each do |officer|
        officer_data  = {
          id: officer[:id],
          first_name: officer[:first_name],
          last_name: officer[:last_name],
          counts: {
            active_members: {
              female: 0,
              male: 0,
              others: 0,
              total: 0,
              members: []
            }
          }
        }

        # Active members
        active_members  = @mc_data[:counts][:active_members][:members].select{ |m|
                            m[:officer][:id] == officer[:id]
                          }

        officer_data[:counts][:active_members][:members] = active_members
        officer_data[:counts][:active_members][:female]  = active_members.select{ |o| o[:gender] == "Female" }.size
        officer_data[:counts][:active_members][:male]    = active_members.select{ |o| o[:gender] == "Male" }.size
        officer_data[:counts][:active_members][:total]   = active_members.size

        @data[:officers] << officer_data
      end

      @data
    end
  end
end
