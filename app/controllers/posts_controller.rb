class PostsController < ApplicationController
  before_action :authenticate_user!, except: :index

  def index
    if current_user
        @ransack = Post.readable_posts(current_user).open_public.ransack(params[:q])
    else
        @ransack = Post.open_public.where(authority: "all").ransack(params[:q])
    end
      @posts = @ransack.result(distinct: true).page(params[:page]).per(20)
  end
end
