module Api
  class AllowanceLossesController < ApiController
    before_action :authenticate_user!

    def generate
      date_select = params[:date_select]
    

      date_select = Array.wrap(date_select)
    
      validator = AllowanceLosses::ValidateGenerate.new(date_select: date_select)
    
      if validator.execute!.present?
        render json: { errors: validator.errors }, status: :unprocessable_entity
      else
        generator = AllowanceLosses::Generate.new(date_select: date_select)
        data = generator.execute!
    
        generate_allowance_losses = AllowanceLosses::GenerateAllowanceLosses.new(data: data)
        processed_data = generate_allowance_losses.execute!
    
        render json: {
          data: processed_data,
        }
      end
    end
    

    def fetch
      puts "Fetch method called"
      @datastore_as_of = DataStore.where(status: 'done')
                                  .where("meta ->> 'data_store_type' = ?", 'ALLOWANCE_COMPUTATION')
                                  .all

      date_as_of = @datastore_as_of.map { |record| record.meta['as_of'] }
  
      render json: { date_as_of: date_as_of }
    end
  end
end
