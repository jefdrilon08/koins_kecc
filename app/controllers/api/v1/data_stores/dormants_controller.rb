module Api
  module V1
    module DataStores
      class DormantsController < ApiController

        def create
          branch = Branch.find(params[:branch_id])
          as_of = params[:as_of]
        
          config = {
            branch: branch,
            as_of: as_of,
            current_user: current_user.id
          }
        
          errors = ::Dormants::ValidateCreate.new(config: config).execute!
          
          if errors[:messages].any?
            render json: errors, status: 400
          else
            # Enqueue the background job and pass the config
            ProcessGenerateDormant.perform_later(config)
        
            render json: { message: 'Dormant creation process started', status: 200 }
          end
        end
        
        
        def add_book_type
          data_store_id = params[:id]
          txtBt = params[:txtBookType]
          data_store = DataStore.find(data_store_id)
        
          if txtBt.present?
            data_store.data['accounting_entry']['book'] = txtBt
            if data_store.save!
              render json: { message: 'Book type added successfully' }, status: 200
            else
              render json: { error: 'Failed to save book type' }, status: 500
            end
          else
            render json: { error: 'Book type cannot be blank' }, status: 400
          end
        end

        def add_or
          data_store_id     = params[:id]
          txtOR    =  params[:txtOR]
          data_store = DataStore.find(data_store_id)
          data_store.data['accounting_entry']['data']['or_number'] = txtOR
          data_store.save!
          render json: { message: "Done" }
        end

        def add_si
          data_store_id     = params[:id]
          txtSI    =  params[:txtSI]
          data_store = DataStore.find(data_store_id)
          data_store.data['accounting_entry']['data']['si_number'] = txtSI
          data_store.save!
          render json: { message: "Done" }
        end

        def add_particular
          data_store_id     = params[:id]
          txtParticular    =  params[:txtParticular]
          
          data_store = DataStore.find(data_store_id)
          data_store.data['accounting_entry']['particular'] = txtParticular
          data_store.save!
          render json: { message: "Done" }
        end


        def approve
          record = DataStore.find(params[:id])
          config = {
          data_store: record.id,
          user: current_user.id
          } 
          args = {
            data_store: record.id,
            user: current_user.id
          }
          record.update(status: "processing")
          ProcessApproveDormants.perform_later(args)
          render json: { message: "ok" }
        end


     
        
      
        
        
        
        
        
        

      end
    end
  end
end