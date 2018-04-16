class CommentsController < BaseController
  before_action :set_post, only: [:create, :update, :destroy, :check_authority, :check_comment_author]
  before_action :set_comment, only: [:update, :destroy, :check_comment_author]
  before_action :check_authority, only: [:create, :update, :destroy]
  before_action :check_comment_author, only: [:update, :destroy]

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      redirect_to post_path(@post)
    else
      flash[:alert] = @comment.errors.full_messages.to_sentence
      redirect_to post_path(@post)
    end
  end

  def update
    if @comment.update(comment_params)
      redirect_to post_path(@post)
    else
      flash[:alert] = @comment.errors.full_messages.to_sentence
      redirect_to post_path(@post)
    end
  end

  def destroy
    @comment.destroy
    redirect_to post_path(@post)
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end

  def check_comment_author
    unless @comment.user == current_user || current_user.admin?
      flash[:alert] = "這不是您的回覆，無法編輯或刪除！"
      redirect_to post_path(@post)
    end
  end

  def check_authority
    unless @post.check_authority_for?(current_user)
      flash[:alert] = "您沒有權限讀取此篇文章"
      redirect_to posts_path
    end
  end
end
