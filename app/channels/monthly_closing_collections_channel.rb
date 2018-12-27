class MonthlyClosingCollectionsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "monthly_closing_collections_channel"
  end

  def unsubscribed
  end
end
