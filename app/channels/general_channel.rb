class GeneralChannel < ApplicationCable::Channel
  def subscribed
    stream_from "general_channel"
  end
end
