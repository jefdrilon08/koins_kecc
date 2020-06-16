module Claims
  class ValidateCalamity

    def initialize(data:, date_prepared:, prepared_by:, claim:)
        @claim                                    = claim
        @data                                     = data
        @date_prepared                            = date_prepared
        @prepared_by                              = prepared_by
        @amount                                   = @data[:amount]
        @date_requested                           = @data[:date_requested]
        @purpose                                  = @data[:purpose]
        @type_of_calamity                         = @data[:type_of_calamity]
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
     count = Claim.where("member_id = ? AND date_prepared = ? AND claim_type = ? AND 
      data->>'amount'= ? AND data->>'date_requested'= ? AND data->>'purpose'= ? AND
      data->>'type_of_calamity'= ? AND data->>'date_of_event'= ? AND data->>'name_of_payee'= ? AND
      data->>'name_of_beneficiary'= ?" , @claim.member_id, @date_prepared, "CALAMITY ASSISTANCE", 
      @amount, @date_requested, @purpose, @type_of_calamity, @date_of_event, @name_of_payee, @name_of_beneficiary).count
      if count > 0 
        @errors << "Duplicate CALAMITY!"
      end
    end
  end
end
