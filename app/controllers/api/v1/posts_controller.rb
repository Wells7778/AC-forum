class Api::V1::PostsController < ApiController
  before_action :authenticate_user!, except: :index

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
    render json: {
      data: @posts.map do |post|
        {
          title: post.title,
          content: post.content,
          image: post.image.current_path ,
          author:
            {
              name: post.user.name,
              email: post.user.email,
              avatar: post.user.avatar.current_path
            },
          comments_count: post.comments_count,
          viewed_count: post.viewed_count
        }
      end
    }
  end

end
