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
    @subheader_items = [
      {
        text: "Billing for Writeoff Collections #{@member_list}"
      }
    ]

  end

end
