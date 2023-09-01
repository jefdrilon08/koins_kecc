class AdditionalShareController < DataStoreController
  def index
  super
    #raise @records.inspect  
    @subheader_items = [
        {
          text: "Additional Share Capital"
        }
      ]

      @subheader_side_actions = [
        {
          id: "btn-new",
          link: "#",
          class: "fa fa-plus",
          text: "New"
        }
      ]
  end

  def show
    @data_store   = DataStore.find(params[:id])
    @branch_id    = @data_store.meta["branch_id"]
    @center_id    = @data_store.meta["center_id"]
    @member_list  = Member.active_and_resigned.where(center_id: @center_id).order("last_name ASC")

    @members      = @member_list.map{ |o| ["#{o["last_name"]}, #{o["first_name"]} ", o["id"] ] }
    
    @data         = @data_store.data.with_indifferent_access
    @data_view    = @data[:record]
    @accounting_entry       = @data[:accounting_entry]
  
    @subheader_items = [       
      {
        is_link: true,         
        path: additional_share_path,
        text: "Additional Share"                                                                            }
    ]
  
    @subheader_side_actions = []    
    if @data_store.status == 'pending'
      if helpers.sbk_mis_bk_oas          
          @subheader_side_actions << {      
            id: "",
            link: "/additional_share/#{@data_store.id}",
            class: "fa fa-times",           
            data: {
                method: :delete,
                confirm: "Are you sure you want to delete this Additional Share?"
            },     
            text: "Delete"    
          }


        end  
    if helpers.sbk_bk_mis_user && current_user.roles.any?
        @subheader_side_actions << {      
        id: "btn-approve",
        link: "#",
        class: "fa fa-check",           
        data: {id: @data_store.id},     
        text: "Approve"    
      }      
    end    
  end


    def destroy
      additional_share = DataStore.find(params[:id])
      if additional_share.pending?
        additional_share.destroy!
        redirect_to additional_share_path
      else
        redirect_to additional_share_path(additional_share)
      end
    end

  end
end
 
