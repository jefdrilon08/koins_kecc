class BillingForWriteoffController < DataStoreController
  def index
  super
    # @records.each do |o|
    #   raise o[:status].inspect
    # end
     @subheader_items = [
        {
          text: "Billing For Writeoff"
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
    super
    @data_store = DataStore.find(params[:id])
    @branch_id = @data_store.meta["branch_id"]
    @data = @data_store.data.with_indifferent_access
    @accounting_entry = @data[:accounting_entry]
   
    @members = Member.active_and_resigned.where(branch_id: @branch_id).order("last_name ASC").map{ |o|
      {
        id: o.id,
        first_name: o.first_name,
        middle_name: o.middle_name,
        last_name: o.last_name,
        branch: {
          id: o.branch.id,
          name: o.branch.name
        },
        center: {
          id: o.center.id,
          name: o.center.name
        }
      }
    }

    @loans = LoanProduct.all.order("name ASC").map{ |o| {
      id: o.id,
      name: o.name
      }
    }

    @subheader_items = [
        {
          is_link: true,
          path: "/billing_for_writeoff",
          text: "Billing For Writeoff / #{@data_store.meta["branch_name"]}"
        }
      ]


    @subheader_side_actions = []
      if @data_store.pending?
        if helpers.sbk_bk_mis_user
            @subheader_side_actions << {
              id: "btn-approve",
              link: "#",
              class: "fa fa-check",
              text: "Approve"
            }
        end
         @subheader_side_actions << {
          link: billing_for_writeoff_path(@data_store.id),
          class: "fa fa-times",
          data: { method: :delete, confirm: "Are you sure?" },
          text: "Delete"
        }
      end


      @payload = {
        id: @data_store.id
      }

  end

  def destroy
  end
end
