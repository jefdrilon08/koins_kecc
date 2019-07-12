module DataStores
  class BuildMemberCountsPerOfficer
    def initialize(mc_data:)
      @mc_data  = mc_data

      @data = {
        officers: []
      }

      @officers = []

      @mc_data[:counts][:loaners][:members].each do |m|
        @officers << m[:officer]
      end

      @mc_data[:counts][:pure_savers][:members].each do |m|
        @officers << m[:officer]
      end

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
            },
            pure_savers: {
              female: 0,
              male: 0,
              others: 0,
              total: 0,
              members: []
            },
            loaners: {
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

        # Pure savers
        pure_savers = @mc_data[:counts][:pure_savers][:members].select{ |m|
                        m[:officer][:id] == officer[:id]
                      }

        officer_data[:counts][:pure_savers][:members] = pure_savers
        officer_data[:counts][:pure_savers][:female]  = pure_savers.select{ |o| o[:gender] == "Female" }.size
        officer_data[:counts][:pure_savers][:male]    = pure_savers.select{ |o| o[:gender] == "Male" }.size
        officer_data[:counts][:pure_savers][:total]   = pure_savers.size

        # Loaners
        loaners = @mc_data[:counts][:loaners][:members].select{ |m|
                    m[:officer][:id] == officer[:id]
                  }

        officer_data[:counts][:loaners][:members] = loaners
        officer_data[:counts][:loaners][:female]  = loaners.select{ |o| o[:gender] == "Female" }.size
        officer_data[:counts][:loaners][:male]    = loaners.select{ |o| o[:gender] == "Male" }.size
        officer_data[:counts][:loaners][:total]   = loaners.size

        @data[:officers] << officer_data
      end

      @data
    end
  end
end
