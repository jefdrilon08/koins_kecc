module Administration
  class MembershipArrangementsController < ApplicationController
    before_action :authenticate_user!

    def index
      @membership_arrangements  = MembershipArrangement.select("*")

      if params[:name].present?
        @membership_arrangements = @membership_arrangements.where(
                    "upper(name) LIKE ?",
                     "%#{params[:name].upcase}%"
                  )
      end

      @membership_arrangements  = @membership_arrangements.order("name ASC").page(params[:page]).per(LIST_PAGE_SIZE)

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          text: "Membership Arrangements"
        }
      ]

      @subheader_side_actions = [
        {
          id: "btn-new",
          link: new_administration_membership_arrangement_path,
          class: "fa fa-plus",
          text: "New Membership Arrangement"
        }
      ]
    end

    def new
      @membership_arrangement = MembershipArrangement.new

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_membership_arrangements_path,
          text: "Membership Arrangements"
        },
        {
          text: "New"
        }
      ]
    end

    def create
      @membership_arrangement = MembershipArrangement.new(membership_arrangement_params)

      if @membership_arrangement.save
        redirect_to administration_membership_arrangement_path(@membership_arrangement)
      else
        @subheader_items = [
          {
            text: "Administration"
          },
          {
            is_link: true,
            path: administration_membership_arrangements_path,
            text: "MembershipArrangements"
          },
          {
            text: "New"
          }
        ]

        render :new
      end
    end

    def edit
      @membership_arrangement = MembershipArrangement.find(params[:id])

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_membership_arrangements_path,
          text: "MembershipArrangements"
        },
        {
          text: "Edit #{@membership_arrangement.name}"
        }
      ]
    end

    def update
      @membership_arrangement = MembershipArrangement.find(params[:id])

      if @membership_arrangement.update(membership_arrangement_params)
        redirect_to administration_membership_arrangement_path(@membership_arrangement)
      else
        @subheader_items = [
          {
            text: "Administration"
          },
          {
            is_link: true,
            path: administration_membership_arrangements_path,
            text: "MembershipArrangements"
          },
          {
            text: "Edit #{@membership_arrangement.name}"
          }
        ]

        render :edit
      end
    end

    def show
      @membership_arrangement = MembershipArrangement.find(params[:id])

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_membership_arrangements_path,
          text: "MembershipArrangements"
        },
        {
          text: "#{@membership_arrangement.name}"
        }
      ]

      @subheader_side_actions = [
        {
          link: edit_administration_membership_arrangement_path(@membership_arrangement),
          class: "fa fa-pencil-alt",
          text: "Edit"
        },
         {
          link: administration_membership_arrangement_path(@membership_arrangement),
          class: "fa fa-times",
          data: { method: :delete, confirm: "Are you sure?" },
          text: "Delete"
        }
      ]

      loan_products = ::LoanProducts::FetchList.new.execute!

      @payload = {
        id: @membership_arrangement.id,
        data: @membership_arrangement.data || {},
        loan_products: loan_products
      }
    end

    def destroy
      @membership_arrangement = MembershipArrangement.find(params[:id])
      @membership_arrangement.destroy!
      flash[:success] = "Successfully removed membership_arrangement"
      redirect_to administration_membership_arrangements_path
    end

    private

    def load_user!
      @membership_arrangement = MembershipArrangement.find(params[:id])
    end

    def membership_arrangement_params
      params.require(:membership_arrangement).permit!
    end
  end
end
