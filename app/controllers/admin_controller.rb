class AdminController < ApplicationController

  before_action :authenticate_user!
  before_action :admin_user?

  def index
    @users = User.all.order("created_at DESC").page(params[:page])
  end

  private

  def admin_user?
    redirect_to root_path unless current_user.admin?
  end

end
