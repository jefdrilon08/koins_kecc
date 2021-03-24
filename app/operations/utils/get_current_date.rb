module Utils
  class GetCurrentDate
    def initialize(config:)
      @config = config

      @branch = @config[:branch]
    end

    def execute!
      if Settings.activate_microloans
        if @branch.present? and @branch.current_date.present?
          @branch.current_date.to_date
        else
          Date.today
        end
      else
        if Settings.current_date.present?
          Settings.current_date
        else
          Date.today
        end   
      end

#      if @branch.present? and Settings.branch_config.present?
#        branch_config = Settings.branch_config.select{ |o|
#                          o.id == @branch.id
#                        }.first
#
#        if branch_config.present? and branch_config.current_date.present?
#          return branch_config.current_date.to_date
#        else
#          return Date.today
#        end
#      elsif Settings.current_date.present?
#        return Settings.current_date.to_date
#      else
#        Date.today
#      end
    end
  end
end
