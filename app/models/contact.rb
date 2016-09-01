class Contact < ActiveRecord::Base
  belongs_to :user
  validates :name, presence: true
  validates_length_of :phone_number, :minimum =>10, :maximum => 12

  after_create :confirmation

  def confirmation
  	@twilio_number = ENV['TWILIO_NUMBER']
    @client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    reminder = "
    	Hi this is the PULSE EMERGENCY. You've been
    	added you into their Emergency Contacts. When Triggered you will get a SMS
    	from our user with a location
    	"
    message = @client.account.messages.create(
      :from => @twilio_number,
      :to => self.phone_number,
      :body => reminder,
    )
    puts message.to
  end

end
