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
end
