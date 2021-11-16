module Loans
  class CreateMakePayment
    def initialize
      @data = {
        records: []
      }
      
    end

    def execute!
      query!
      @data[:records] = @result.map{
            
        (1..12).to_a.each do |m|
        
        end


      }
    end

    private
    def query!
      @result = ActiveRecord::Base.connection.execute(<<-EOS).to_a
                  SELECT 
                    * 
                  From
                    amortization_schedule_entries ase 
                  WHERE 
                    ase.loan_id = 'd42e1f6b-14bc-4d45-8dbd-f59fd5b5a355' and 
                    is_paid is null
                EOS
    end

  end
end
