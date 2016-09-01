require 'twilio-ruby'

class NotificationsController < ApplicationController
	def trigger_sms_alert
		@link = params[:link]
		@user = User.find_by(id: session[:user_id])
		@alert_message = 
			"
			This has been triggered by our user: #{@user.first_name} #{@user.last_name}
			There has been some kind of emergency at #{@link}
			Please contact #{@user.first_name} or wait until they get back to you
			with more information. 
			"
		#this should get all of the emergency contact from the clients list
		@emergency_contact_list = Contact.where(user_id: session[:user_id])

		begin
			@emergency_contact_list.each do |contact|
				phone_number = contact['phone_number']
				send_message(phone_number, @alert_message)
			end
		end
		redirect_to :back
	end
	private

	def send_message(phone_number, alert_message)
		# twilio_number = "+18082011403"
		twilio_number = ENV['TWILIO_NUMBER']
		# @client = Twilio::REST::Client.new Key.find_by(name:'Test_Account_Sid').key, Key.find_by(name:'Test_Auth_Token').key 
		@client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'] 
		message = @client.account.messages.create(
			:from => twilio_number,
			:to => phone_number,
			:body => alert_message,
			# US phone numbers can make use of an image as well
				)
		puts message.to
	end
end





















