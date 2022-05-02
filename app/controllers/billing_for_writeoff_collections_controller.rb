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
    @billing_data_store = DataStore.find(params[:id])
    @member_list = @billing_data_store.data['record'].map{|o| "#{o['member_id']}"}
    @subheader_items = [
      {
        text: "Billing for Writeoff Collections #{@member_list}"
      }
    ]

  end

end
