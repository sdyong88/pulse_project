class User < ActiveRecord::Base
  has_secure_password
  has_many :contacts, dependent: :destroy
  validates :email,  presence: true, format: { with: /\A.+@.+$\Z/ }, uniqueness: true
  validates :first_name,:last_name, presence: true
  validates :country_code, presence: true
  validates :password, presence: true
  validates :phone_number, presence: true
end
