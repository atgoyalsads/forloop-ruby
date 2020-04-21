class Api::V1::DashboardsController < Api::V1::ApplicationController
	before_action :validateSession

	def dashboardCategories
		categories = Category.all.paginate(page: params[:page], per_page: params[:per_page])
		render json: {code: 200, categories: categories.as_json(only: [:title], methods: [:id]), total_pages: categories.total_pages}
	end

	def dashboardSubCategories
		available = User.where("skillSet"=> {:$exists=>true},  "deactivated": false).pluck(:skillSet).flatten.map{|s| s["subcategoryId"]}.uniq
		if params[:category_id].present?
			subcategories = Subcategory.where(category_id: params[:category_id], :_id.in=> available).paginate(page: params[:page], per_page: params[:per_page])
		else
			subcategories = Subcategory.where(:_id.in=> available).paginate(page: params[:page], per_page: params[:per_page])
		end
		subcatsJson = []
		subcategories.each do |subcat|
			users = User.where("skillSet.subcategoryId"=> subcat._id, "deactivated": false).paginate(page: 1, per_page: 3)
			subcatsJson << subcat.as_json(only: [:title], methods: [:id]).merge(users: users.as_json(userAttributes))
		end
		render json: {code: 200, subcategories: subcatsJson}
	end

	def dashboardTop
		topUsers = User.where("skillSet"=>  {:$exists=>true},  "deactivated": false).paginate(page: params[:page], per_page: params[:per_page])
		render json: {code: 200, top: topUsers.as_json(userAttributes) }
	end

	def subcategoryUsers
		begin
			subcat = Subcategory.find_by(:_id=> params[:subcategory_id])
			users = User.where("skillSet.subcategoryId"=> subcat._id, "deactivated": false).paginate(page: params[:page], per_page: params[:per_page])
			render json: {code: 200, users: users.as_json(userAttributes)}
		rescue Exception => e
			render json: {code: 200, users: []}
		end
	end

	def searchProUsers
		searchterm = params[:keyword].to_s
  	users = User.where("deactivated": false).any_of({"skillSet.subcategoryTitle"=> /.*#{searchterm}.*/i}, {"skillSet.categoryTitle"=> /.*#{searchterm}.*/i}, {:fname => /.*#{searchterm}.*/i}, {:lname => /.*#{searchterm}.*/i }, {:displayName => /.*#{searchterm}.*/i }).paginate(page: params[:page], per_page: params[:per_page])
  	if !users.present?
  		uids = RatingQuestion.where({:question=> /.*#{searchterm}.*/i}).distinct(:receiverUserId).paginate(page: params[:page], per_page: params[:per_page])
  		users = User.where(:_id.in=> uids).paginate(page: params[:page], per_page: params[:per_page])
  	end
  	render json: {code: 200, users: users.as_json(userAttributes)}
	end

	def proDashboard
		today = Date.current
		result = []
		availableOptions = []
		reqOpt = params[:requestOption].to_i>0 ? params[:requestOption].to_i : 1
		case params[:keyword]
		when "monthly"
			availableOptions = 1.upto(today.month).to_a.reverse.map{ |m| {label1: today.year, label2: monthName(m), value: m} }
			mname = monthName(today.month)
			endday = (today.month==reqOpt) ? today.day : "01-#{reqOpt}-#{today.year}".to_date.end_of_month.day
			1.upto(endday).each do |day|
				startFrom = "#{day}-#{reqOpt}-#{today.year}".to_date.beginning_of_day
				endAt = "#{day}-#{reqOpt}-#{today.year}".to_date.end_of_day
				cval = CallHistory.where(receiverUserId: @user._id,:created_at.gte => startFrom, :created_at.lte => endAt).size
				result << {label: "#{day} #{mname}", value: cval}
			end
		when "weekly"
			# availableOptions = 
			1.upto(4).each do |opNum|
				fromDate = toDate = Date.today
				(Date.today-((7*opNum)-1).days).upto(Date.today-((opNum-1)*7)).each_with_index do |day, indx|
					if indx==0
						fromDate = day 
					elsif indx==6
						toDate = day
					end
				end
				availableOptions<<{label1: "#{fromDate.day} #{monthName(fromDate.month)}-#{toDate.day} #{monthName(toDate.month)}", label2: "Week #{opNum}", value: opNum}
			end
			
			(Date.today-((7*reqOpt)-1).days).upto(Date.today-((reqOpt-1)*7)).each do |day|
				startFrom = day.beginning_of_day
				endAt = day.end_of_day
				cval = CallHistory.where(receiverUserId: @user._id,:created_at.gte => startFrom, :created_at.lte => endAt).size
				result << {label: "#{day.day} #{monthName(day.month)}", value: cval}
			end

		else
			# Yearly
			availableOptions = 2020.upto(today.year).to_a.reverse.map{ |y| {label1: nil, label2: y, value: y} }
			1.upto(today.month).each do |month|
				startFrom = "01-#{month}-#{reqOpt}".to_date.beginning_of_month
				endAt = "01-#{month}-#{reqOpt}".to_date.end_of_month
				cval = CallHistory.where(receiverUserId: @user._id,:created_at.gte => startFrom, :created_at.lte => endAt).size
				result << {label: monthName(month), value: cval}
			end
		end

		calls = CallHistory.where(receiverUserId: @user._id).order(created_at: 'DESC').paginate(page: 1, per_page: 5).as_json(only: [:durationMinutes, :totalPrice,:created_at], methods: [:id], include: {dialer: {only: [:fname, :lname, :image]} })
		render json: {code: 200, availableOptions: availableOptions,  result: result.reverse, requestOption: reqOpt, calls: calls}
	end

	private
	def userAttributes
		{ only: [:displayName, :image, :description, :pricePerHour], methods: [:id, :skills, :callsDataHome ] }
	end

	def monthName month
		"01-#{month}-2020".to_date.strftime("%B").first(3)
	end
end