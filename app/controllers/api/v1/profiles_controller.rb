class Api::V1::ProfilesController < Api::V1::ApplicationController
	before_action :validateSession
	def show
		returnUserJson
	end

	def proDetails
		begin
			pro = User.find_by(:_id => params[:proUserId])
			inFav = Favourite.where(user_id: @user._id, favouriteUserId: pro._id).present?
			ratings = CallHistory.where(receiverUserId: pro._id, :callRating.gte=>1).order(callRating: "DESC").paginate(page: 1, per_page: 3).as_json(only: [:callReview, :created_at], methods: [:rating, :reviewedBy, :id])
			questions  = ratings.count>0 ? RatingQuestion.where(call_history_id: ratings[ratings.count-1]["id"]).as_json({only: [:question, :isAnswered]}) : []
			render :json =>  {code: 200, user: pro.as_json(proAttributes).merge(inFav: inFav, ratings: ratings, questions: questions)}
		rescue Exception => e
			render :json =>  {code: 404, message: "Profile does not exists"}         
		end
	end

	def proRatings
		begin
			pro = User.find_by(:_id => params[:proUserId])
			ratings = CallHistory.where(receiverUserId: pro._id, :callRating.gte=>1).paginate(page: params[:page], per_page: params[:per_page]).as_json(only: [:callReview, :created_at], methods: [:rating, :reviewedBy])
			render :json =>  {code: 200, ratings: ratings}
		rescue Exception => e
			render :json =>  {code: 404, message: "Profile does not exists"}         
		end
	end

	def checkContact
		begin
			if @user.countryCode.present? and @user.contact.present?
			prepareClient
			outgoing_caller_ids = @client.outgoing_caller_ids
                             .list(phone_number: "#{@user.countryCode}#{@user.contact}", limit: 1)
			
				if outgoing_caller_ids.present?
					render json: {code: 200, message: "Contact verified"}
				else
					render json: {code: 100, verificationCode: verificationCall, message: "Contact saved but not verified"}
				end
			else
		  	render json: {code: 404, message: "Contact does not exists"}
			end
		rescue Exception => e
		  render json: {code: 400, message: e}
		end
		
	end

	def updateContact
		@user.set({"updated_at": Time.current, "countryCode": params[:countryCode], "contact": params[:contact]})
		begin
	  	render json: {code: 200, verificationCode: verificationCall}
		rescue Exception => e
	  	render json: {code: 404, message: e}
		end
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
		@user.set("updated_at": Time.current, "fname": params[:fname], "lname": params[:lname], "zipcode": params[:zipcode], "dob": params[:dob], "gender": params[:gender], "proDataStatus.details": true)
	  returnUserJson
	end

	def update_links
		@user.set("updated_at": Time.current, "linkBlogger": params[:linkBlogger], "linkLinkedin": params[:linkLinkedin], "linkInstagram": params[:linkInstagram], "linkPinterest": params[:linkPinterest], "proDataStatus.links": true)
	  returnUserJson
	end

	def update_details
		@user.set({"updated_at": Time.current, "description": params[:description], "pricePerHour": params[:pricePerHour], "certificates": params[:certificates].map{|pr| pr.to_enum.to_h}, "proDataStatus.price": true})
	  returnUserJson
	end

	def update_subcategories
		subcats = Subcategory.where(:_id.in => params[:subcategories].to_a)
		addedSubcategories = []
		subcats.each do |subcat|
			data = @user.subcategory_users.find_or_create_by(subcategory: subcat,category_id: subcat.category_id)
			addedSubcategories << {subcategoryId: subcat._id, subcategoryTitle: subcat.title}
		end
		@user.set("updated_at": Time.current, "proDataStatus.subcategories": true, "skillSet": addedSubcategories)
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
	  render json: {code: 200, message: "Record Found", user: @user.as_json(userJson).merge({sessionToken: request.headers["sessiontoken"]})}
	end

	def userJson
		{ except:[:created_at,:updated_at,:password_hash,:password_salt,:_id, :skillSet, :stripeCustomerId], methods: [:skillsJson]}
	end

	def proAttributes
		{ only: [:fname, :lname, :countryCode, :contact, :displayName, :image, :description, :pricePerHour], methods: [:id, :allSkills, :callsDataDetail] }
	end

	def prepareClient
		@client = Twilio::REST::Client.new @@account_sid, @@auth_token
	end

	def verificationCall
		prepareClient
		validation_request = @client.validation_requests
                            .create(
                               friendly_name: "#{@user.email}",
                               phone_number: "#{@user.countryCode}#{@user.contact}"
                            )
		validation_request.validation_code 
	end
end
