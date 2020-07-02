module Claims
  class ClaimAttachmentFilesController < ApplicationController
    before_action :load_defaults

    def load_defaults
      @claim = Claim.find(params[:claim_id])
    end

    def new
      @claim_attachment_file = ClaimAttachmentFile.new
    end

    def create
      @claim_attachment_file = ClaimAttachmentFile.new(claim_attachment_file_params)
      @claim_attachment_file.claim = @claim

      if @claim_attachment_file.save
        flash[:success] = "Successfully created claim"
        redirect_to claim_path(@claim)
      else
        flash[:error] = "Error in creating claim_attachment_file"
        render :new
      end
    end

    def edit
      @claim_attachment_file = ClaimAttachmentFile.find(params[:id])
    end

    def show
      @claim_attachment_file = ClaimAttachmentFile.find(params[:id])
    end

    def update
      @claim_attachment_file = ClaimAttachmentFile.find(params[:id])
      
      if @claim_attachment_file.update(claim_attachment_file_params)
        redirect_to claim_path(@claim)
      else
        flash[:error] = "Error in saving claim"
        render :new
      end
    end

    def destroy
      @claim_attachment_file    = ClaimAttachmentFile.find(params[:id])
      @claim_attachment_file.file.purge
      @claim_attachment_file.destroy!

      redirect_to claim_path(@claim)
    end

    def claim_attachment_file_params
      params.require(:claim_attachment_file).permit(:file_name, :file, :data)
    end

  end
end
