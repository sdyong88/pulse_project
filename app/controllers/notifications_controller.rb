class NotificationsController < ApplicationController
	rescue_from EmergencyContact do |contacts|
		trigger_sms_alerts(contacts)
	end

	def trigger_sms_alert(e)
		@alert_message = "
			[This is a test] ALERT!
			IT appears #{e} has an emergency

			"
		#this should get all of the emergency contact from the clients list
		@emergency_contact_list 
		#doc loads a YAML file
		# @admin_list - YAML.load_file('config/adminstrators.yml')

		begin
			@emergency_contact_list.each do |admin|
				phone_number = contact['phone_number']
				send_message(phone_number, @alert_message)
			end
			flash[:success] = "Exception #{e}. Emergency Contacts will be notified"
		rescue
			flash[:alert] = "Something went wrong"
		end
		redirect_to "/"

	end

	private
	def send_message(phone_number, alert_message)
		@twilio_number = ENV['TWILIO_NUMBER']
		@client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV["TWILIO_AUTH_TOKEN"]

		message = @client.account.messages.create(
			:from => @twilio_number,
			:to => phone_number,
			:body => alert_message,
			# US phone numbers can make use of an image as well
				)
		puts message.to
	end
end





















