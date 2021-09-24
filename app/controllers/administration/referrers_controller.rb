module Administration
  class ReferrersController < ApplicationController
    before_action :authenticate_user!
    before_action :load_referrer!, only: [:show, :edit, :update]

    def index
      @referrers  = Referrer.select("*")

      if params[:name].present?
        @referrers = @referrers.where(
                    "lower(first_name) LIKE ? OR lower(last_name) LIKE ?",
                     "%#{params[:name].downcase}%", "%#{params[:name].downcase}%"
                  )
      end

      @referrers  = @referrers.order("last_name ASC").page(params[:page]).per(LIST_PAGE_SIZE)

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          text: "Referrers"
        }
      ]

      @subheader_side_actions = [
        {
          id: "btn-new",
          link: new_administration_referrer_path,
          class: "fa fa-plus",
          text: "New Referrer"
        }
      ]
    end

    def new
      @referrer = Referrer.new

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_referrers_path,
          text: "Referrers"
        },
        {
          text: "New Referrer"
        }
      ]

      @subheader_side_actions = []
    end

    def create
      @referrer = Referrer.new(referrer_params)

      if @referrer.save
        redirect_to administration_referrer_path(@referrer)
      else
        @subheader_items = [
          {
            text: "Administration"
          },
          {
            is_link: true,
            path: administration_referrers_path,
            text: "Referrers"
          },
          {
            text: "New Referrer"
          }
        ]

        @subheader_side_actions = []

        render :new
      end
    end

    def edit
      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_referrers_path,
          text: "Referrers"
        },
        {
          text: "Edit Referrer: #{@referrer.id}"
        }
      ]

      @subheader_side_actions = []
    end

    def update
      if @referrer.update(referrer_params)
        redirect_to administration_referrer_path(@referrer)
      else
        @subheader_items = [
          {
            text: "Administration"
          },
          {
            is_link: true,
            path: administration_referrers_path,
            text: "Referrers"
          },
          {
            text: "Edit Referrer: #{@referrer.id}"
          }
        ]

        @subheader_side_actions = []

        render :edit
      end
    end

    def show
      @refers = @referrer.members
      @coor_refers = Member.where(coordinator_id: @referrer.id)

      @subheader_items = [
        {
          text: "Administration"
        },
        {
          is_link: true,
          path: administration_referrers_path,
          text: "Referrers"
        },
        {
          text: "Referrer: #{@referrer.id}"
        }
      ]

      @subheader_side_actions = []

      @payload = {
        id: @referrer.id
      }
    end

    private

    def load_referrer!
      @referrer = Referrer.find(params[:id])
    end

    def referrer_params
      params.require(:referrer).permit!
    end
  end
end
