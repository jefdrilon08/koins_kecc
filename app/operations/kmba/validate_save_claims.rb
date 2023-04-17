module Kmba
  class ValidateSaveClaims < AppValidator 
    def initialize(config:)
      super()
      @config               = config
      # raise @config.inspect
    end

    def execute!
      if @config.blank?
        @errors[:messages] << {
          key: "no_member", 
          message: "No Member Record Found!"
        }
      elsif @config.nil?
        @errors[:messages] << {
          key: "no_member", 
          message: "No Member Record Found!"
        }
      else 
        @config.map{ |a|
          if a.blank?
            @errors[:messages] << {
              key: "no_member", 
              message: "No Member Record Found!"
            }
          end

          if a.nil?
            @errors[:messages] << {
              key: "no_member", 
              message: "No Member Record Found!"
            }
          end

          if a[:date_prepared].blank?
            @errors[:messages] << {
              member_id: a[:member_id],
              key: "date_prepared", 
              message: "Date Prepared not found"
            }
          end

          if a[:prepared_by].blank?
            @errors[:messages] << {
              id: a[:prepared_by],
              key: "prepared_by", 
              message: "Prepared By not found"
            }
          end

          i

          # validate created_at and updated_ata
          # member_id : uuid microsite         
        }
      end

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors  
    end
  end
end