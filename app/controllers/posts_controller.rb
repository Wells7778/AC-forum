class PostsController < ApplicationController
  before_action :authenticate_user!, except: :index
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def index
    @categories = Category.all
    if current_user
      if params[:category_id]
        @category = Category.find(params[:category_id])
        @ransack = @category.posts.readable_posts(current_user).open_public.ransack(params[:q])
      else
        @ransack = Post.readable_posts(current_user).open_public.ransack(params[:q])
      end
    else
      if params[:category_id]
        @category = Category.find(params[:category_id])
        @ransack = @category.posts.open_public.where(authority: "All").ransack(params[:q])
      else
        @ransack = Post.open_public.where(authority: "All").ransack(params[:q])
      end
    end
      @posts = @ransack.result(distinct: true).includes(:comments).page(params[:page]).per(20)
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)
    if params[:commit] == "Save Draft"
      @post.public = false
      @post.save
      redirect_to root_path
    else
      @post.public = true
      @post.save
      redirect_to post_path(@post)
    end
  end

  def show
    @post.vieweds.create(user: current_user) unless @post.viewed_by?(current_user)
    @comments = @post.comments.page(params[:page]).per(20)
    @comment = Comment.new
  end

  private

  def post_params
    params.require(:post).permit(:title, :content, :image, :public, :authority, category_ids: [])
  end

  def set_post
    @post = Post.find(params[:id])
  end
end
