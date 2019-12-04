module Members
  class AttachmentFilesController < ApplicationController
    before_action :load_defaults

    def load_defaults
      @member = Member.find(params[:member_id])
    end

    def new
      @attachment_file = AttachmentFile.new
    end

    def create
      @attachment_file = AttachmentFile.new(attachment_file_params)
      @attachment_file.member = @member

      if @attachment_file.save
        flash[:success] = "Successfully created claim"
        redirect_to member_path(@member)
      else
        flash[:error] = "Error in creating attachment_file"
        render :new
      end
    end

    def edit
      @attachment_file = AttachmentFile.find(params[:id])
    end

    def show
      @attachment_file = AttachmentFile.find(params[:id])
    end

    def update
      @attachment_file = AttachmentFile.find(params[:id])
      
      if @attachment_file.update(attachment_file_params)
        redirect_to member_path(@member)
      else
        flash[:error] = "Error in saving claim"
        render :new
      end
    end

    def destroy
      @attachment_file    = AttachmentFile.find(params[:id])
      @attachment_file.file.purge
      @attachment_file.destroy!

      redirect_to member_path(@attachment_file.member)
    end

    def attachment_file_params
      params.require(:attachment_file).permit(:file_name, :file, :data)
    end

  end
end
