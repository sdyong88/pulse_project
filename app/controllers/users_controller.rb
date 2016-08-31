require 'authy'
require 'twilio-ruby'

# Authy.api_key = Key.find_by(name:'Authy.api_key').key
Authy.api_key = ENV['AUTHY_KEY']
Authy.api_uri = 'https://api.authy.com/'

class UsersController < ApplicationController
  def index
  end

  def new
    @user = User.new
  end

  def show
    @user = current_user
    @contacts = current_user.contacts
  end

  def create
  	@user = User.new(user_params)
  	if @user.save
  		# Save the user_id to the session object
  		session[:user_id] = @user.id

  		# Create user on Authy, will reutrn an id on the object
  		authy = Authy::API.register_user(
        :email => @user.email,
        :cellphone => @user.phone_number,
        :country_code => '1'
        )
      if authy.ok?
        @user.update(authy_id: authy.id)# this will give the user authy id to store it in the database
      else
        @user.delete
        fail
      end
  		#Sends an SMS to your user
  		Authy::API.request_sms(id: @user.authy_id)
  		redirect_to verify_path
  	else
      flash[:errors] = @user.errors.full_messages
  		redirect_to '/users/new'
  	end
  end

  def show_verify
  	return redirect_to new_user_path unless session[:user_id]
  end

  def verify
  	@user = User.find(session[:user_id])
  	#Use Authy to send the verficiation token
  	token = Authy::API.verify(id: @user.authy_id, token: params[:token])
    puts token
  	if token.ok?
  		# Mark the user as verified for get /user/:id
  		#Send an SMS to the user for success!
  		send_message("Sign up complete")
  		#show the user profile
  		redirect_to user_path(@user.id)
  	else
  		flash.now[:danger] = "Incorrect Code, Please Try again"
  		render :show_verify
  	end
  end

  def resend
  	@user = current_user
  	Authy::API.request_sms(id: @user.authy_id)
  	flash[:notice] = "Verification code re-sent"
  	redirect_to verify_path
  end

  private


  def send_message(message)
  	@user = current_user
  	# twilio_number = "+18082011403"
    twilio_number = ENV['TWILIO_NUMBER']
  	@client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    # @client = Twilio::REST::Client.new Key.find_by(name:'Test_Account_Sid').key, Key.find_by(name:'Test_Auth_Token').key
  	message = @client.account.messages.create(
  		:from => twilio_number,
  		:to => @user.phone_number,
  		:body => message
  		)
  	puts message.to
  end

  def user_params
  	params.require(:user).permit(:first_name,:last_name,:email,:password,:phone_number, :country_code, :authy_id)
  end
end
