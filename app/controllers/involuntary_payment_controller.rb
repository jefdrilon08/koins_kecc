class InvoluntaryPaymentController < ApplicationController
    def index
      @records = DataStore.where("meta ->> ? = ?", 'data_store_type', 'INVOLUNTARY_PAYMENT')
                          .order(created_at: :desc)
                          .page(params[:page]) 
                          .per(10)              
      
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
        #raise @data_store.data['record'].inspect
        @get_members            = @data_store.data['record'].select{|o| o["enabled"] == false}
        @member_with_writeoff   = @get_members.map{|o| "#{o['member_id']}"}
        @member_list            = Member.where("id IN (?)" , @member_with_writeoff)
        @member_list_item       = @member_list.map{ |o| ["#{o["last_name"]}, #{o["first_name"]} ", o["id"] ] }
        @data                   = @data_store.data.with_indifferent_access
        @data_view              = @data[:record].select{|x| x["enabled"] == true}
        @accounting_entry       = @data[:accounting_entry]
    
        @subheader_items = [
          {
            is_link: true,
            path: involuntary_payment_path,
            text: "Billing for Involuntary"
          }
        ]
        
        @subheader_side_actions = []
        if @data_store.status == 'pending'
          if helpers.sbk_bk_mis_user
            @subheader_side_actions << {      
              id: "",
              link: "/involuntary_payment/#{@data_store.id}",
              class: "fa fa-times",           
              data: {
                method: :delete,
                confirm: "Are you sure you want to delete this Involuntary Collection?"
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
  end

  def delete
  involuntary_collections = DataStore.find(params[:id])
    if involuntary_collections.pending?
      involuntary_collections.destroy!
      redirect_to involuntary_payment_path
    else
      redirect_to  involuntary_collections_path(involuntary_collections)
    end
  end
end