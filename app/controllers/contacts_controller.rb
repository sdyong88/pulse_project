class ContactsController < ApplicationController

	def create
		@user = User.find_by(id: session[:user_id])
		number = params[:contact][:phone_number]
		scan_number = number.scan(/\d+/).join

		if scan_number[0] =="+" && scan_number[1] == "1"
			scan_number = number.prepend("+1")
		end

		@contact = @user.contacts.create(
			name: params[:contact][:name],
			phone_number: scan_number,
			user_id: params[:contact][:user_id]
			)

		if @contact.valid?
			redirect_to :back
		else
			flash[:errors] = @contact.errors.full_messages
			redirect_to :back
		end
	end

	private
	def contact_params
		params.require(:contact).permit(:name,:phone_number, :user_id)
	end
end
