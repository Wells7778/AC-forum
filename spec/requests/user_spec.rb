RSpec.describe 'User', type: :request do
  let(:user1) { create(:user, email: FFaker::Internet.email) }
  let(:post1) { create(:post, user: user1)}
  let(:draft1) { create(:draft, user: user1)}
  let(:comment1) { create(:comment, user: user1, post: post2) }
  let(:collect1) { create(:collection, user: user1, post: post2) }

  let(:user2) { create(:user, email: FFaker::Internet.email) }
  let(:post2) { create(:post, user: user2)}
  let(:post2_for_self) { create(:post_for_self, user: user2) }
  let(:post2_for_friend) { create(:post_for_friend, user: user2) }
  let(:comment2) { create(:comment, user: user2, post: post1) }
  let(:collect2) { create(:collection, user: user2, post: post1) }
  let(:user3) { create(:user, email: FFaker::Internet.email) }
  context '#show' do
    before do
      user1
      user2
      post1
      draft1
      post2
      post2_for_self
      post2_for_friend
      sign_in(user1)
    end

    describe '自己的profile' do
      it '顯示自己的文章' do
        get user_path(user1)
        expect(assigns(:posts).ids).to include post1.id
        expect(assigns(:posts).ids).not_to include draft1.id
      end
    end

    describe '其他人的profile' do
      it '顯示其他人的文章' do
        get user_path(user2)
        expect(assigns(:posts).ids).to include post2.id
        expect(assigns(:posts).ids).not_to include post2_for_self.id
        expect(assigns(:posts).ids).not_to include post2_for_friend.id
      end
    end
  end

  context '#edit' do
    before do
      user1
      sign_in(user1)
    end

    describe 'go to edit page' do
      it 'will render edit page' do
        get edit_user_path(user1)
        expect(response).to render_template(:edit)
      end

      it 'will redirect if not this user' do
        get edit_user_path(user2)
        expect(response).to redirect_to(user_path(user2))
      end
    end
  end

  context '#update' do
    before do
      user1
      sign_in(user1)
    end

    describe 'successfully update' do
      it 'will change users info' do
        expect(user1.description).to be nil
        patch "/users/#{user1.id}", params: {
          user: {
            description: 'description'
          }
        }
        user1.reload
        expect(user1.description).to_not be_nil
        expect(user1.description.length).not_to be_zero
      end
    end
  end

  context '#drafts' do

    before do
      user1
      user2
      post1
      draft1
      post2
      post2_for_self
      sign_in(user1)
    end

    describe '到自己的草稿夾頁面' do
      it '會顯示所有草稿' do
        get drafts_user_path(user1)
        expect(assigns(:drafts).ids).to include draft1.id
        expect(assigns(:drafts).ids).not_to include post1.id
      end
    end

    describe '到其他人的草稿夾頁面' do
      it '無法開啟會跳回show頁面' do
        get drafts_user_path(user2)
        expect(response).to redirect_to(user_path(user2))
      end
    end
  end

  context '#comments' do
    before do
      user1
      user2
      post1
      post2
      comment1
      comment2
      sign_in(user1)
    end

    describe '到自己的回覆頁面' do
      it '會顯示所有回覆' do
        get comments_user_path(user1)
        expect(assigns(:comments).ids).to include comment1.id
        expect(assigns(:comments).ids).not_to include comment2.id
      end
    end

    describe '到其他人的回覆頁面' do
      it '會顯示其他人的所有回覆' do
         get comments_user_path(user2)
        expect(assigns(:comments).ids).to include comment2.id
        expect(assigns(:comments).ids).not_to include comment1.id
      end
    end
  end

  context '#collects' do
    before do
      user1
      user2
      post1
      post2
      collect1
      collect2
      sign_in(user1)
    end

    describe '到自己的收藏頁面' do
      it '會顯示所有收藏' do
        get collects_user_path(user1)
        expect(assigns(:collections).ids).to include post2.id
        expect(assigns(:collections).ids).not_to include post1.id
      end
    end

    describe '到其他人的收藏頁面' do
      it '無法開啟會跳回show頁面' do
        get collects_user_path(user2)
        expect(response).to redirect_to(user_path(user2))
      end
    end
  end
  context '#friends' do
    before do
      user1
      user2
      Friendship.create(user: user1, friend: user2, status: true)
      Friendship.create(user: user1, friend: user3, status: false)
      sign_in(user1)
    end
    describe '到自己的好友頁面' do
      it '會顯示所有好友' do
        get friends_user_path(user1)
        expect(assigns(:friends)).to include user2
        expect(assigns(:not_yet_accepted_by_friends)).to include user3
      end
    end

    describe '到其他人的好友頁面' do
      it '無法開啟會跳回show頁面' do
        get friends_user_path(user2)
        expect(response).to redirect_to(user_path(user2))
      end
    end
  end
end
