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
    @member_list             = Member.where(branch_id: @branch_id).where(status: ['active', 'writeoff']).order("last_name ASC")
    @data                   = @data_store.data.with_indifferent_access
    @data_view              = @data[:records]
    @accounting_entry_transfer_savings  = @data[:accounting_entry_transfer_savings]
    @accounting_entry_loan_payments = @data[:accounting_entry_loan_payments]
    @subheader_side_actions = []



    if helpers.sbk_bk_mis_user
      if @data_store.pending?
        @subheader_side_actions << {
          id: "btn-approve",
          link: "#",
          class: "fa fa-check",
          text: "Approve"
        }
      end
    end

    @subheader_side_actions << {
          id: "btn-print-entry",
          link: "#",
          class: "fa fa-check",
          text: "Print Entry",
          data: {
            id: "#{@data_store.id}"
        }
    }
    @subheader_side_actions << {
      id: "btn-print",
      link: "#",
      class: "fa fa-check",
      text: "Print Details",
      data: {
        id: "#{@data_store.id}"
    }
}
    if @data_store.status == 'pending'
      if helpers.sbk_bk_mis_user
          @subheader_side_actions << {
            id: "",
            link: "/billing_for_involuntary/#{@data_store.id}",
            class: "fa fa-times",
            data: {
                method: :delete,
                confirm: "Are you sure you want to delete this Involuntary Tagging?"
            },
            text: "Delete"
          }


        end
    end





    @payload = {
      id: @data_store.id
    }
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
