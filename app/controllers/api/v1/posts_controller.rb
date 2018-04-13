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

  def show
    @post = Post.find_by(id: params[:id])
    if Post.readable_posts(current_user).open_public.include?(@post)
      @post.vieweds.create(user: current_user) unless @post.viewed_by?(current_user)
      @comments = @post.comments
      render json: {
        data: {
          title: @post.title,
          content: @post.content,
          image: @post.image.current_path ,
          author:
            {
              name: @post.user.name,
              email: @post.user.email,
              avatar: @post.user.avatar.current_path
            },
          comments_count: @post.comments_count,
          viewed_count: @post.viewed_count,
          comments: @comments.map do |comment|
            {
              content: comment.content,
              comment_author:
                {
                  name: comment.user.name,
                  email: comment.user.email,
                  avatar: comment.user.avatar.current_path
                }
            }
          end
        }
    }
    else
      render json: {
        errors: "權限不足"
      }
    end
  end

end
