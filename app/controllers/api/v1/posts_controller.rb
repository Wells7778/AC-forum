class Api::V1::PostsController < ApiController
  before_action :authenticate_user!, except: :index
  before_action :set_post, only: [:show, :update, :destroy, :check_author]
  before_action :check_author, only: [:update, :destroy]

  def index
    if current_user
      if params[:category_id]
        @category = Category.find(params[:category_id])
        @posts = @category.posts.readable_posts(current_user).open_public
      else
        @posts = Post.readable_posts(current_user).open_public
      end
    else
      if params[:category_id]
        @category = Category.find(params[:category_id])
        @posts = @category.posts.open_public.where(authority: "all")
      else
        @posts = Post.open_public.where(authority: "all")
      end
    end
    render "api/v1/posts/index"
  end

  def show
    if !@post
      render json: {
        message: "Can't find the post!",
        status: 400
      }
    else
      if Post.readable_posts(current_user).open_public.include?(@post)
        @post.vieweds.create(user: current_user) unless @post.viewed_by?(current_user)
        @comments = @post.comments
        render "api/v1/posts/show"
      else
        render json: {
          errors: "權限不足"
        }
      end
    end
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      render json: {
        message: "成功新增文章",
        result: @post
      }
    else
      render json: {
        errors: @post.errors
      }
    end
  end

  def update
    if @post.update(post_params)
      render json: {
        message: "成功更新文章",
        result: @post
      }
    else
      render json: {
        errors: @post.errors
      }
    end
  end

  def destroy
    @post.destroy
    render json: {
      message: "成功刪除文章"
    }
  end

  private
  def set_post
    @post = Post.find_by(id: params[:id])
  end

  def post_params
    params.permit(:title, :content, :image, :public, :authority, category_ids: [])
  end

  def check_author
    unless @post.user == current_user || current_user.admin?
      render json: {
        errors: "這不是你的文章喔"
      }
    end
  end
end
