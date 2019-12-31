class Api::V1::ProfilesController < Api::V1::ApplicationController
	before_action :validateSession

	def show
		proData = proScreensStatus(@user)
	  render json: {code: 200, message: "Record Found", user: @user.as_json(except:[:created_at,:updated_at,:password_hash,:password_salt,:_id]).merge({proDataStatus: proData,sessionToken: request.headers["sessiontoken"]})}		
	end

	def update_role
		@user.update(selectedRole: params[:selectedRole]=="pro" ? "pro" : "learner")
		proData = proScreensStatus(@user)
	  render json: {code: 200, message: "Record Found", user: @user.as_json(except:[:created_at,:updated_at,:password_hash,:password_salt,:_id]).merge({proDataStatus: proData,sessionToken: request.headers["sessiontoken"]})}
	end

	def upload_pic
		if params[:image].present?
			@user.update(image: params[:image],displayName: params[:displayName])
		else
			@user.update(displayName: params[:displayName])
		end
	  render json: {code: 200, message: "Record updated", user: @user.as_json(only:[:image,:displayName])}
	end

	def update_profile
		@user.update(fname: params[:fname], lname: params[:lname], zipcode: params[:zipcode], countryCode: params[:countryCode], contact: params[:contact], dob: params[:dob], gender: params[:gender])
	  render json: {code: 200, message: "Record updated", user: @user.as_json(only: [:fname, :lname, :zipcode, :countryCode, :contact, :gender, :dob])}
	end

	def update_links
		@user.update(linkBlogger: params[:linkBlogger], linkLinkedin: params[:linkLinkedin], linkInstagram: params[:linkInstagram], linkPinterest: params[:linkPinterest])
	  render json: {code: 200, message: "Record updated", user: @user.as_json(only: [:linkBlogger, :linkLinkedin, :linkInstagram, :linkPinterest])}
	end

	def update_details
		@user.update(description: params[:description], pricePerHour: params[:pricePerHour])
		if params[:certificate1].present?
	  	@user.update(certificate1: params[:certificate1])
	  end
	  if params[:certificate2].present?
	  	@user.update(certificate2: params[:certificate2])
	  end
	  render json: {code: 200, message: "Record updated", user: @user.as_json(only: [:description,:certificate1,:certificate2,:pricePerHour])}
	end

	def categories
		categories = Category.all.paginate(page: params[:page],per_page: params[:per_page])
	  render json: {code: 200, message: "Record updated", categories: categories.as_json(only: [:title], methods: [:id])}
	end

	def subcategories_list
		begin
			category = Category.find(params[:categoryId])	
			subcats = category.subcategories.paginate(page: params[:page], per_page: params[:per_page])
	  	render json: {code: 200, message: "Record fetched", categories: subcats.as_json(only: [:title], methods: [:id])}
		rescue Exception => e
	  	render json: {code: 401, message: "Category does not exists"}
		end
	end

	def update_subcategories
		subcats = Subcategory.where(:_id.in => params[:subcategories].to_a)
		subcats.each do |subcat|
			@user.subcategory_users.create(subcategory: subcat)
		end
		selected = @user.subcategory_users.count
	  render json: {code: 200, message: "Record fetched",selected: selected, subcategories: subcats.as_json(only: [:title], methods: [:id])}
	end
end
