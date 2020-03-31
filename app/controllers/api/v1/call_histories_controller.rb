class Api::V1::CallHistoriesController < Api::V1::ApplicationController
	before_action :validateSession
	before_action :findCall, except: [:callHistory]
	before_action :checkRatingParams, only: [:rateCall]

	def callHistory

		if params[:keyword].present?
			searchterm = params[:keyword].to_s.downcase
			uids = User.any_of({ :fname => /.*#{searchterm}.*/i }, { :lname => /.*#{searchterm}.*/i }).pluck(:_id)
			history = CallHistory.any_of({:dialerUserId => @user._id, :receiverUserId.in => uids}, {:receiverUserId => @user._id, :dialerUserId.in => uids}).order(updated_at: "DESC").paginate(page: params[:page], per_page: params[:per_page])
		else
			history = @user.callHistories.order(updated_at: "DESC").paginate(page: params[:page], per_page: params[:per_page])
		end
		result = []
		history.each do |res|
			user = res.dialerUserId.as_json["$oid"]==@user._id.as_json["$oid"] ? res.receiver.as_json(userAttributes) : res.dialer.as_json(userAttributes)
			result << res.as_json(listCallAttributes).merge({user: user})
		end
		render json: {code: 200, history: result }
	end

	def callDetails
		questions = @call.rating_questions.as_json({only: [:question, :isAnswered]})
		render json: {code: 200, call: @call.as_json(callAttributes.merge({include: {:dialer=> userAttributes, :receiver=> userAttributes}})).merge({questions: questions})}	
	end

	def rateCall
		begin
			askedQuestions = []
			params[:questions].each do |quest|
				@call.rating_questions.create(question: quest[:label], rating: quest[:rating].to_f, isAnswered: !(quest[:isAnswered]==false), receiverUserId: @call.receiverUserId, user_id: @user._id)
				askedQuestions << {question: quest[:label], rating: quest[:rating].to_f, isAnswered: !(quest[:isAnswered]==false)}
			end
			@call.set({tip: params[:tip].to_f, callReview: params[:review], callRating: params[:rating], feedbackQuestionAddressed: params[:questionAddressed], feedbackNotLiked: params[:notLiked], feedbackNewFeatures: params[:newFeatures], askedQuestions: askedQuestions})
			render json: {code: 200, message: "Review added successfully" }
		rescue Exception => e
			render json: {code: 400, message: e}	
		end
	end

	private
	def findCall
		begin
			@call = @user.callHistories.find_by(_id: params[:callId])
		rescue Exception => e
			render :json =>  {code: 404, message: "Call does not exists"}         
		end
	end

	def callAttributes
		{ except: [:_id, :dialerUserId, :receiverUserId ,:callRating, :stripeChargeId, :stripeMessage, :pickedAt, :paidStatus, :connectedAt, :completedAt, :updated_at, :askedQuestions], methods: [:id, :rating, :receiverId] }
	end

	def listCallAttributes
		{ only: [:durationMinutes, :totalPrice, :created_at], methods: [:id, :rating] }
	end

	def userAttributes
		{only: [:image, :fname, :lname,:email]}
	end

	def checkRatingParams
		unless params[:questions].present?
			render :json =>  { code: 404, message: "Questions must be present"}         
		end
	end
end

