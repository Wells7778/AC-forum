class UsersController < BaseController
  before_action :set_user, only: [:show, :edit, :update, :check_user, :drafts, :comments, :collects, :friends]
  before_action :check_user, except: [:show, :comments]

  def show
    @posts = @user.posts.open_public
  end

  def update
    @user.update(user_params)

    redirect_to user_path(@user)
  end

  def comments
    @comments = @user.comments
  end

  def collects
  end

  def drafts
    @drafts = @user.posts.where(public: false)
  end

  def friends
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