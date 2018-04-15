RSpec.describe 'Friendship', type: :request do
  let(:user1) { create(:user, email: FFaker::Internet.email) }
  let(:user2) { create(:user, email: FFaker::Internet.email) }

  context '#create' do
    describe 'user1申請user2好友' do
      before do
        user1
        user2
        sign_in(user1)
        post friendships_path, xhr: true, params: { friend_id: user2.id }
      end

      it '增加一個好友請求給user2' do
        expect(Friendship.count).to eq 1
        expect(Friendship.last.friend_id).to eq user2.id
        expect(Friendship.last.status).to eq false
      end
    end
  end

  context '#accept' do
    describe 'user1接受user2交友請求' do
      before do
        user1
        user2
        Friendship.create(user: user2, friend: user1)
        sign_in(user1)
        post accept_friendship_path(user2), xhr: true
      end

      it 'user1和user2變成好友' do
        expect(Friendship.last.status).to eq true
        expect(user1.all_friends).to include user2
        expect(user2.all_friends).to include user1
      end
    end
  end

  context '#ignore' do
    describe 'user1忽略user2交友請求' do
      before do
        user1
        user2
        Friendship.create(user: user2, friend: user1)
        sign_in(user1)
        delete ignore_friendship_path(user2), xhr: true
      end

      it 'user1 user2不是好友' do
        expect(Friendship.count).to eq 0
      end
    end
  end
end