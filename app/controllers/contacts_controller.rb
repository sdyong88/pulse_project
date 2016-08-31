class ContactsController < ApplicationController

	def create
		@user = User.find_by(id: session[:user_id])
		@contact = @user.contacts.create(contact_params)
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
