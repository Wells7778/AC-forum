class UsersController < BaseController
  before_action :set_user, only: [:show, :edit, :update, :check_user, :drafts, :comments, :collects, :friends]
  before_action :check_user, except: [:show, :comments]

  def show
    @posts = @user.posts.readable_posts(current_user).open_public
  end

  def update
    @user.update(user_params)

    redirect_to user_path(@user)
  end

  def comments
    @comments = @user.comments.includes(:post)
  end

  def collects
    @collections = @user.collect_posts.includes(:collect_users)
  end

  def drafts
    @drafts = @user.posts.where(public: false)
  end

  def friends
    @friends = @user.all_friends
    @not_yet_accepted_by_friends = @user.not_yet_accepted_by_friends
    @not_yet_responded_to_friends = @user.not_yet_responded_to_friends
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :description, :avatar)
  end

  def check_user
    unless @user == current_user
      flash[:alert] = "這不是您的檔案！"
      redirect_to user_path(@user)
    end
  end
end