class SessionsController < ApplicationController


	def create
		user = User.find_by_email(params[:email])
		if user
			session[:user_id] = user.id
			redirect_to user_path(user.id)
		else
			flash[:errors] = ["Invalid Combo"]
			redirect_to :back
		end
	end

	def destroy
		session[:user_id] = nil
		redirect_to "/"
	end
end