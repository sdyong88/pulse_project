require 'authy'
require 'twilio-ruby'

Authy.api_key = 'LdBse3mHAr3pGnMGBp3yj0Mi69cPdFcd'
Authy.api_uri = 'https://api.authy.com/'

class UsersController < ApplicationController
  def new
    @user = User.new
  end
  def show
    @user = User.find_by(id: session[:user_id])
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
  		render :new
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
  		# @user.update(verified:true)
  		#Send an SMS to the user for success!

  		# send_message("Sign up complete")

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
  @twilio_number = '4086178899'
  # ideally would pull from data base for validation key
  @twilio_account_sid = 'AC8dac8cfa4d451bdb5ae909f7ded9c7cc'
  @twilio_auth_token = 'c1c4e60971ca34a9b7964c019ceaba22'

  def send_message(message)
  	@user = current_user
    puts '========='
    puts @user
    puts '========='
  	twilio_number = ENV[@twilio_number]
  	@client = Twilio::REST::Client.new ENV[@twilio_account_sid], ENV[@twilio_auth_token]
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
