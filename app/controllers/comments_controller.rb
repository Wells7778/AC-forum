class CommentsController < BaseController
  before_action :set_post, only: [:create, :destroy, :check_authority]
  before_action :check_authority, only: [:create, :destroy]

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

  def destroy
    @comment = @post.comments.find(params[:id])
    if @comment.user == current_user || current_user.admin?
      @comment.destroy

      redirect_to post_path(@post)
    else
      flash[:alert] = "這不是您的回覆喔！"
      redirect_to post_path(@post)
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end

  def check_authority
    unless @post.check_authority_for?(current_user)
      flash[:alert] = "您沒有權限讀取此篇文章"
      redirect_to posts_path
    end
  end
end
