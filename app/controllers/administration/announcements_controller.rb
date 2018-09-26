module Administration
  class AnnouncementsController < ApplicationController
    before_action :authenticate_user!

    def index
      @announcements  = Announcement.select("*")
    end

    def new
      @announcement = Announcement.new
    end

    def create
      @announcement = Announcement.new(announcement_params)
      @announcement.user_id = current_user.id

      if @announcement.save
        redirect_to administration_announcement_path(@announcement)
      else
        render :new
      end
    end

    def edit
      @announcement = Announcement.find(params[:id])
    end

    def update
      @announcement = Announcement.find(params[:id])

      if @announcement.update(announcement_params)
        redirect_to administration_announcement_path(@announcement)
      else
        render :edit
      end
    end

    def show
      @announcement = Announcement.find(params[:id])
    end

    private

    def load_user!
      @announcement = Announcement.find(params[:id])
    end

    def announcement_params
      params.require(:announcement).permit!
    end
  end
end
