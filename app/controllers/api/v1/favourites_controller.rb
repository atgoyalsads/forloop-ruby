class Api::V1::FavouritesController < Api::V1::ApplicationController
	before_action :validateSession
	
	def create
		begin
			profile = User.find_by(:_id => params[:favouriteUserId])
			fav = @user.favourites.where(:favouriteUserId => profile._id).first
			if fav
				fav.destroy
				render json: {code: 200, status: false}
			else
				@user.favourites.create(:favouriteUserId => profile._id)
				render json: {code: 200, status: true}
			end
		rescue Exception => e
			render :json =>  {code: 404, message: "Profile does not exists"}         
		end
	end

	def list
		favsUids = @user.favourites.paginate(page: params[:page], per_page: params[:per_page]).pluck(:favouriteUserId)
		users = User.where(:_id.in=> favsUids)
		render json: {code: 200, profiles: users.as_json(only: [:displayName, :image, :description, :pricePerHour], methods: [:id, :skills])}
	end
end
