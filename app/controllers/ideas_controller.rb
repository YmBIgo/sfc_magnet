class IdeasController < ApplicationController

  before_action :authenticate_user!
  before_action :profile_check

  def new
    @idea = Idea.new
  end

  def create
    if current_user.ideas.count < 3
      @idea = Idea.create(create_params)
    else
      flash[:fail] = "Too much Ideas"
    end
  end

  def index
    @ideas = Idea.all.order("created_at DESC").page(params[:page])
  end

  def show
    @idea = Idea.find(params[:id])
  end

  def edit
    @idea = Idea.find(params[:id])
  end

  def update
    @idea = Idea.find(params[:id])
    @idea.update(update_params)
  end

  private

  def profile_check
    redirect_to root_path unless current_user.full_profile?
  end

  def create_params
    params.require(:idea).permit(:name, :outline, :type_id, :invention, :user_id).merge(user_id: current_user.id)
  end

  def update_params
    params.require(:idea).permit(:name, :outline, :type_id, :invention)
  end

end
