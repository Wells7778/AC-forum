class FriendshipsController < BaseController
  def create
    @friendship = current_user.not_yet_accepted_by_friendships.build(friend_id: params[:friend_id])
    @friendship.save
    @user = User.find(params[:friend_id])
    respond_to do |format|
      format.js
    end
  end

  def accept
    @friendship = current_user.not_yet_responded_to_friendships.find_by(user_id: params[:id])
    @friendship.update(status: true)
    @user = User.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def ignore
    @friendship = current_user.not_yet_responded_to_friendships.find_by(user_id: params[:id])
    @friendship.destroy
    @user = User.find(params[:id])
    respond_to do |format|
      format.js
    end
  end
end
