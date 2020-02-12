class Api::V1::DashboardsController < Api::V1::ApplicationController
	before_action :validateSession

	def seeker
		usersCats = SubcategoryUser.distinct(:category_id)
		categories = Category.where(:_id.in => usersCats).paginate(page: 1, per_page: 4)

		if params[:category_id].present?
			subcategories = Subcategory.where(category_id: params[:category_id]).paginate(page: 1, per_page: 3)
		elsif categories.present?
			subcategories = categories.first.subcategories.paginate(page: 1, per_page: 3)
		else
			subcategories = Subcategory.all.paginate(page: 1, per_page: 3)
		end 
		
		subcatsJson = []
		subcategories.each do |subcat|
			userIds = subcat.subcategory_users.order(updated_at: "DESC").distinct(:user_id)
			users = User.where(:_id.in=>userIds).paginate(page: 1, per_page: 3)
			subcatsJson << subcat.as_json(only: [:title], methods: [:id]).merge(users: users.as_json(only: [:displayName, :image, :description, :pricePerHour], methods: [:id, :skills]))
		end
		topUids = SubcategoryUser.distinct(:user_id).first(6)
		topUsers = User.where(:_id.in=>topUids).paginate(page: 1, per_page: 6)
		result = {categories: categories.as_json(only: [:title], methods: [:id]), subcategories: subcatsJson, top: topUsers.as_json(only: [:displayName, :image, :description, :pricePerHour], methods: [:id, :skills])}
		render json: {code: 200, result: result}
	end

	def subcategoryUsers
			userIds = SubcategoryUser.where(subcategory_id: params[:subcategory_id]).order(updated_at: "DESC").distinct(:user_id)
			users = User.where(:_id.in=>userIds).paginate(page: params[:page], per_page: params[:per_page])
			render json: {code: 200, users: users.as_json(only: [:displayName, :image, :description, :pricePerHour], methods: [:id, :skills])}
	end

	def searchProUsers
		begin
			searchterm = params[:keyword].to_s
			cats = Category.where({ :title => /.*#{searchterm}.*/i }).paginate(page: 1, per_page: 10).pluck(:id)
			subcats = Subcategory.any_of({ :title => /.*#{searchterm}.*/i }, :category_id.in => cats).paginate(page: 1, per_page: 10).pluck(:id)
	  	userIds = SubcategoryUser.where(:subcategory_id.in => subcats).order(updated_at: "DESC").distinct(:user_id).paginate(page: 1, per_page: 10)
	  	users = User.where(:_id.in=>userIds).paginate(page: params[:page], per_page: params[:per_page])
	  	render json: {code: 200, users: users.as_json(only: [:displayName, :image, :description, :pricePerHour], methods: [:id, :skills])}
		rescue Exception => e
	  	render json: {code: 401, message: "Category does not exists"}
		end
	end
end
