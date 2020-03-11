module Claims
  class ValidateCalamity

    def initialize(data:, date_prepared:, prepared_by:, claim:)
        @claim                                    = claim
        @data                                     = data
        @date_prepared                            = date_prepared
        @prepared_by                              = prepared_by
        @date_requested                           = @data[:date_requested]
        @purpose                                  = @data[:purpose]
        @type_of_calamity                         = @data[:type_of_calamity]
        @amount                                   = @data[:amount]
        @date_of_event                            = @data[:date_of_event]
        @name_of_payee                            = @data[:name_of_payee]
        @name_of_beneficiary                      = @data[:name_of_beneficiary]


        @errors = []

    end

    def execute!
      if @date_requested.blank?
        @errors << "Date requested field is empty"
      end
      if @purpose.blank?
        @errors << "Purpose field is required"
      end

      if @type_of_calamity.blank?
        @errors << "Type of Calamity field is required"
      end

      if @amount.blank?
        @errors << "Amount field is required"
      end

      if @date_of_event.blank?
        @errors << "Date of event field is required"
      end

      if @name_of_payee.blank?
        @errors << "Name of payee field is required"
      end

      if @name_of_beneficiary.blank?
        @errors << "Name of beneficiary is required"
      end

      validate_calamity_duplication!
      return  @errors
    end

    private

    def validate_calamity_duplication!
     count = Claim.where("claim_type = ? AND data->>'date_of_event'= ?" , "CALAMITY ASSISTANCE", @date_of_event).count
        if count > 0 
          @errors << "Duplicate CALAMITY!"
        end
        
    end
  end
end
