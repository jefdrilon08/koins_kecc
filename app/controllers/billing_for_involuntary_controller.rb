class BillingForInvoluntaryController < DataStoreController
  def index
    super
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
     @data_store              = DataStore.find(params[:id])
     @branch_id               = @data_store.meta['branch_id']
     @member_list             = Member.active.where(branch_id: @branch_id).order("last_name ASC")
      @data                   = @data_store.data.with_indifferent_access
      @data_view              = @data[:records]
      @accounting_entry       = @data[:accounting_entry]
      


      @subheader_items = [
      {
        is_link: true,
        path: billing_for_involuntary_path,
        text: "Billing for Involuntary"
      }
    ]
    
    @subheader_side_actions = []
    if @data_store.status == 'pending'
      if helpers.sbk_bk_mis_user
        @subheader_side_actions << {      
          id: "",
          link: "/billing_for_involuntary/#{@data_store.id}",
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
  end 
  def destroy
    billing_for_involuntary = DataStore.find(params[:id])
    if billing_for_involuntary.pending?
      billing_for_involuntary.destroy!
      redirect_to billing_for_involuntary_path
    else
      redirect_to billing_for_involuntary_path(billing_for_involuntary)
    end
  end
end
