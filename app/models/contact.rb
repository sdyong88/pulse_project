class Contact < ActiveRecord::Base
  belongs_to :user
  validates :name, presence: true
  validates_length_of :phone_number, :minimum =>10, :maximum => 12

  after_create :confirmation

  def confirmation
  	@twilio_number = ENV['TWILIO_NUMBER']
    @client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    reminder = "
    	Hi this is the PULSE. You have been added by one of our users as one of their Emergency Contacts. You will now be alerted if they are in trouble.
    	"
    message = @client.account.messages.create(
      :from => @twilio_number,
      :to => self.phone_number,
      :body => reminder,
    )
    puts message.to
  end

end
