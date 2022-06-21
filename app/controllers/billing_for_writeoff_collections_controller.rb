class BillingForWriteoffCollectionsController < DataStoreController
  def index
    super
    #raise @records.inspect  
    @subheader_items = [
        {
          text: "Billing for Writeoff Collections"
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
    @data_store             = DataStore.find(params[:id])
    #@member_with_writeoff = @data_store.data['record'].map{|o| "#{o['member_id']}"}
    @get_members            = @data_store.data['record'].select{|o| o["enabled"] == false}
    @member_with_writeoff  = @get_members.map{|o| "#{o['member_id']}"}
    @member_list            = Member.where("id IN (?)" , @member_with_writeoff)
    @member_list_item       = @member_list.map{ |o| ["#{o["last_name"]}, #{o["first_name"]} ", o["id"] ] }
    @data                   = @data_store.data.with_indifferent_access
    @data_view              = @data[:record].select{|x| x["enabled"] == true}
    @accounting_entry       = @data[:accounting_entry]

    @subheader_items = [
      {
        is_link: true,
        path: billing_for_writeoff_collections_path,
        text: "Billing for Writeoff Collections"
      }
    ]
    @subheader_side_actions = []
    if @data_store.status == 'pending'
      if helpers.sbk_bk_mis_user
        @subheader_side_actions << {      
          id: "",
          link: "/billing_for_writeoff_collections/#{@data_store.id}",
          class: "fa fa-times",           
          data: {
            method: :delete,
            confirm: "Are you sure you want to delete this Writeoff Collection?"
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
      writeoff_collections = DataStore.find(params[:id])
      if writeoff_collections.pending?
         writeoff_collections.destroy!
        redirect_to billing_for_writeoff_collections_path
      else
        redirect_to  billing_for_writeoff_collections_path(writeoff_collections)
      end
    end

  end
end
