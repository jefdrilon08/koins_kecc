module Billings
  class ValidateApprove < AppValidator
    def initialize(config:)
      super()

      @config   = config
      @billing  = @config[:billing]
      @user     = @config[:user]

      @current_date = @config[:current_date] || Date.today

      @data = @billing.try(:data).try(:with_indifferent_access)
    end

    def execute!
      if !@billing.checked?
        @errors[:messages] << {
          key: "billing",
          message: "this record has not been checked yet"
        }
      end

      if @billing.blank?
        @errors[:messages] << {
          key: "billing",
          message: "billing not found"
        }
      end

      if @data.present? and @data[:or_number].blank?
        @errors[:messages] << {
          key: "or_number",
          message: "no or number found"
        }
      end

      if @billing.collection_date.try(:to_date) > @current_date
        @errors[:messages] << {
          key: "collection_date",
          message: "Cannot approve billing dated #{@billing.collection_date} for current date #{@current_date}"
        }
      end

      if @data.present? and @data[:accounting_entry][:particular].blank?
        @errors[:messages] << {
          key: "particular",
          message: "no particular found"
        }
      end

      #not_yet_implemented!

      @errors[:full_messages] = @errors[:messages].map{ |o| o[:message] }

      @errors
    end
  end
end
