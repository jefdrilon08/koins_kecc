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
    @data_store = DataStore.find(params[:id])
    @member_with_writeoff = @data_store.data['record'].map{|o| "#{o['member_id']}"}
    @member_list = Member.where("id IN (?)" , @member_with_writeoff)
    @member_list_item = @member_list.map{ |o| ["#{o["last_name"]}, #{o["first_name"]} ", o["id"] ] }

    #raise @member_list_item.inspect
    
    @subheader_items = [
      {
        text: "Billing for Writeoff Collections #{@member_list}"
      }
    ]

  end

end
