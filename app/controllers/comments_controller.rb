class CommentsController < BaseController
  before_action :set_post, only: [:create, :destroy]

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user
    @comment.save!
    redirect_to post_path(@post)
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
end
