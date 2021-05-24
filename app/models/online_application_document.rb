class OnlineApplicationDocument < ApplicationRecord
  belongs_to :online_application

  has_one_attached :file
end
