class PostsController < ApplicationController
  before_action :authenticate_user!, except: :index

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
        @ransack = @category.posts.open_public.where(authority: "all").ransack(params[:q])
      else
        @ransack = Post.open_public.where(authority: "all").ransack(params[:q])
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

  private

  def post_params
    params.require(:post).permit(:title, :content, :image, :draft, :authority, category_ids: [])
  end

end
