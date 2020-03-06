class Api::V1::ProfilesController < Api::V1::ApplicationController
	before_action :validateSession

	def show
		returnUserJson
	end

	def update_role
		@user.set(updated_at: Time.current, selectedRole: params[:selectedRole]=="pro" ? "pro" : "learner")
		returnUserJson
	end

	def upload_pic
		@user.set({"updated_at": Time.current, "image": params[:image], "displayName": params[:displayName], "proDataStatus.displayName": true})
	  returnUserJson
	end

	def update_profile
		@user.set("updated_at": Time.current, "fname": params[:fname], "lname": params[:lname], "zipcode": params[:zipcode], "countryCode": params[:countryCode], "contact": params[:contact], "dob": params[:dob], "gender": params[:gender], "proDataStatus.details": true)
	  returnUserJson
	end

	def update_links
		@user.set("updated_at": Time.current, "linkBlogger": params[:linkBlogger], "linkLinkedin": params[:linkLinkedin], "linkInstagram": params[:linkInstagram], "linkPinterest": params[:linkPinterest], "proDataStatus.links": true)
	  returnUserJson
	end

	def update_details
		@user.set("updated_at": Time.current, "description": params[:description], "pricePerHour": params[:pricePerHour], "certificates": eval(params[:certificates].to_s), "proDataStatus.price": true)
	  returnUserJson
	end

	def update_subcategories
		subcats = Subcategory.where(:_id.in => params[:subcategories].to_a)
		subcats.each do |subcat|
			@user.subcategory_users.find_or_create_by(subcategory: subcat,category_id: subcat.category_id)
		end
		@user.set("updated_at": Time.current, "proDataStatus.subcategories": true)
	  returnUserJson
	end

	def subcategories_list
		begin
			searchterm = params[:keyword].to_s
			cats = Category.where({ :title => /.*#{searchterm}.*/i }).paginate(page: 1, per_page: params[:per_page]).pluck(:id)
			subcats = Subcategory.any_of({ :title => /.*#{searchterm}.*/i }, :category_id.in => cats).paginate(page: params[:page], per_page: params[:per_page])
	  	render json: {code: 200, message: "Record fetched", subcategories: subcats.as_json(only: [:title], methods: [:id])}
		rescue Exception => e
	  	render json: {code: 401, message: "Category does not exists"}
		end
	end

	private
	def returnUserJson
	  render json: {code: 200, message: "Record Found", user: @user.as_json(except:[:created_at,:updated_at,:password_hash,:password_salt,:_id]).merge({sessionToken: request.headers["sessiontoken"]})}
	end
end
