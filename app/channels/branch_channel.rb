class BranchChannel < ApplicationCable::Channel
  def subscribed
    stream_from "branch_channel_#{params[:room]}"
  end
end
