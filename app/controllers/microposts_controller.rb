class MicropostsController < ApplicationController
	before_action :signed_in_user, only: [:create, :destroy, :show]
	before_action :correct_user, only: :destroy
	def create
		@micropost = current_user.microposts.build(micropost_params)
		if @micropost.save
			flash[:success] = "Post created!"
			redirect_to root_url
		else
			@feed_items = []
			render 'static_pages/home'	
		end		
	end

	def destroy
		@micropost.destroy
		redirect_to root_url
	end

	def show
		@microposts = Micropost.all
		@users = User.all
		puts "----------------------------------"
		puts "#{@users}"
		puts "----------------------------------"
	end

	private 

	def micropost_params
		params.require(:micropost).permit(:content)
	end

	def correct_user
		@micropost = current_user.microposts.find_by(id: params[:id])
		redirect_to root_url if @micropost.nil?
	end
end