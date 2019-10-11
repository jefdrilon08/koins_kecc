class User < ApplicationRecord
  include Rails.application.routes.url_helpers

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  REMOTE_ROLES = [
    "REMOTE-OAS",
    "REMOTE-BK",
    "REMOTE-MIS",
    "REMOTE-FM",
    "REMOTE-OM"
  ]

  ROLES = [
    "OAS",
    "BK",
    "SBK",
    "CM",
    "SO",
    "FM",
    "AM",
    "MIS",
    "ACC",
    "AO",
    "REMOTE-OAS",
    "REMOTE-BK",
    "REMOTE-MIS",
    "REMOTE-FM",
    "REMOTE-OM"
  ]

  validates :username, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :identification_number, presence: true, uniqueness: true

  # ActiveStorage
  has_one_attached :profile_picture
  has_many :announcements

  serialize :roles, Array

  attr_accessor :login

  def current_roles
    self.roles.select{ |o|
      o.present?
    }
  end

  def is_mis?
    roles.include?("MIS")
  end

  def is_admin?
  end

  def profile_picture_url
    if self.profile_picture.attached?
      return rails_blob_path(self.profile_picture, disposition: "attachment", only_path: true)
    else
      "#{ENV['HOST']}/#{ ActionController::Base.helpers.asset_path('missing_profile_picture.png')}"
    end
  end

  def to_s
    full_name
  end

  def full_name
    "#{last_name.upcase}, #{first_name.upcase}"
  end

  def print_full_name
    "#{first_name.upcase} #{last_name.upcase}"
  end

  def login=(login)
    @login  = login
  end

  def login
    @login || self.username || self.email
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).first
    else
      if conditions[:username].nil?
        where(conditions).first
      else
        where(username: conditions[:username]).first
      end
    end
  end
end
