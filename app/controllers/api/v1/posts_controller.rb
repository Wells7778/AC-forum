class Api::V1::PostsController < ApiController
  before_action :authenticate_user!, except: :index
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
          categories: @post.categories.map do |category|
            {
              name: category.name
            }
          end,
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

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      render json: {
        message: "Post created successfully!",
        result: @post
      }
    else
      render json: {
        errors: @post.errors
      }
    end
  end

  def update
    @post = Post.find_by(id: params[:id])
    if @post.update(post_params)
      render json: {
        message: "post updated successfully!",
        result: @post
      }
    else
      render json: {
        errors: @post.errors
      }
    end
  end
  private

  def post_params
    params.permit(:title, :content, :image, :public, :authority, category_ids: [])
  end

  def check_author
    @post = Post.find_by(id: params[:id])
    unless @post.user == current_user || current_user.admin?
      render json: {
        errors: "這不是你的文章喔"
      }
    end
  end
end
