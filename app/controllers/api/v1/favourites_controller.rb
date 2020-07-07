class Api::V1::FavouritesController < Api::V1::ApplicationController
	before_action :validateSession
	
	def create
		begin
			profile = User.find_by(:_id => params[:favouriteUserId])
			fav = @user.favourites.to_a.include?(profile._id)
			if fav
				@user.set({"favourites": @user.favourites.to_a-[profile._id] })
				render json: {code: 200, status: false}
			else
				@user.set({"favourites": (@user.favourites.to_a<<profile._id)})
				render json: {code: 200, status: true}
			end
		rescue Exception => e
			render :json =>  {code: 404, message: "Profile does not exists"}         
		end
	end

	def list
		users = User.where(:_id.in=> @user.favourites.to_a).paginate(page: params[:page], per_page: params[:per_page])
		render json: {code: 200, profiles: users.as_json(only: [:displayName, :image, :description, :pricePerHour], methods: [:id, :skills])}
	end
end
