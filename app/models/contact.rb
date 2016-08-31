class Contact < ActiveRecord::Base
  belongs_to :user
  validates :name, presence: true
  validates_length_of :phone_number, :minimum =>10, :maximum => 12

end
