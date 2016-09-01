class ContactsController < ApplicationController

	def create
		@user = User.find_by(id: session[:user_id])
		number = params[:contact][:phone_number]
		@scan_number = number.scan(/\d+/).prepend("+1").join.to_s
		@test_number = "#{params[:country_code]}" + "#{number}"

		puts '==========='
		puts @scan_number.to_s
		puts '============='
		puts params[:contact][:name]
		puts '============='

		
		@contact = @user.contacts.create(
			name: params[:contact][:name],
			phone_number: @scan_number,
			user_id: params[:contact][:user_id]
			)

		if @contact.valid?
			puts 'Success'
			redirect_to :back
		else
			flash[:errors] = @contact.errors.full_messages
			puts @scan_number+ "did not get inserted"
			redirect_to :back
		end
	end

	def destroy
		Contact.find(params[:contact_id]).destroy
		redirect_to '/users/show'
	end

	private
	def contact_params
		params.require(:contact).permit(:name,:phone_number, :user_id)
	end
end
