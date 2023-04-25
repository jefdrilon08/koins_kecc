class MbsTransferController < DataStoreController
  def index
  super
    #raise @records.inspect  
    @subheader_items = [
        {
          text: "MBS Transfer"
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
        path: mbs_transfer_path,
        text: "MBS TRANSFER"                                                                            }
    ]
  
    @subheader_side_actions = []    
    if @data_store.status == 'pending'
      if helpers.sbk_bk_mis_user          
          @subheader_side_actions << {      
            id: "",
            link: "/mbs_transfer/#{@data_store.id}",
            class: "fa fa-times",           
            data: {
                method: :delete,
                confirm: "Are you sure you want to delete this Additional Share?"
            },     
            text: "Delete"    
          }

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
      mbs_transfer = DataStore.find(params[:id])
      if mbs_transfer.pending?
        mbs_transfer.destroy!
        redirect_to mbs_transfer_path
      else
        redirect_to mbs_transfer_path(mbs_transfer)
      end
    end

  end

end
