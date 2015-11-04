class UsersController < ApplicationController

  before_action :authenticate_user!
  before_action :profile_check,  only:[:index, :show]

  def index
    # @users = User.all.includes(:school, :job).order("created_at DESC").page(params[:page])
    @users = User.search(params)
    @ideas = Idea.all.order("created_at DESC").page(params[:page])
  end

  def show
    @user = User.find(params[:id])
    @ideas = @user.ideas.page(params[:page])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.update(update_params)
  end

  private

  def profile_check
    redirect_to root_path unless current_user.full_profile?
  end

  def update_params
    params.require(:user).permit(:family_name, :avatar, :first_name, :school_id, :job_id, :self_intro, :skill)
  end

end
