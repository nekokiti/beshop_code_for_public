class UserKeywordsController < ApplicationController
	before_action :sign_in_required
	def index
    @user_keywords = UserKeyword.page(params[:page]).order(counts: "DESC")
	end
end
