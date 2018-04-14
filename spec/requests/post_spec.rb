RSpec.describe 'Post', type: :request do
  let(:user1) { create(:user, email: FFaker::Internet.email) }
  let(:post1) { create(:post, user: user1)}
  let(:post1_for_self) { create(:post_for_self, user: user1) }
  let(:post1_for_friend) { create(:post_for_friend, user: user1) }
  let(:draft1) { create(:draft, user: user1)}

  let(:user2) { create(:user, email: FFaker::Internet.email) }
  let(:post2) { create(:post, user: user2)}
  let(:post2_for_self) { create(:post_for_self, user: user2) }
  let(:post2_for_friend) { create(:post_for_friend, user: user2) }
  let(:draft2) { create(:draft, user: user2)}

  let(:user3) { create(:user, email: FFaker::Internet.email) }
  let(:post3) { create(:post, user: user3)}
  let(:post3_for_self) { create(:post_for_self, user: user3) }
  let(:post3_for_friend) { create(:post_for_friend, user: user3) }
  let(:draft2) { create(:draft, user: user3)}

  let(:comment2_by_user1) { create(:comment, user: user1, post: post2) }
  let(:comment2_by_user2) { create(:comment, user: user2, post: post2) }
  let(:comment2_by_user3) { create(:comment, user: user3, post: post2) }

  context '#index' do
    describe '未登入' do
      before do
        user1
        post1
        user2
        post2
        get posts_path
      end
      it 'can render index' do
        expect(response).to render_template(:index)
      end

      it '能看見文章列表，文章權限為all文章' do
        expect(assigns(:posts)).to eq [post1,post2]
      end
    end

    context '使用者登入' do
      before do
        user1
        post1
        post1_for_self
        post1_for_friend
        draft1
        user2
        post2
        post2_for_self
        post2_for_friend
        user3
        post3
        post3_for_self
        post3_for_friend
        draft2
        Friendship.create(user: user1, friend: user2, status: true)
        sign_in(user1)
        get posts_path
      end

      it 'can render index' do
        expect(response).to render_template(:index)
      end

      describe '能看見' do
        it '自己所有文章列表' do
          expect(assigns(:posts).ids).to include post1.id
          expect(assigns(:posts).ids).to include post1_for_friend.id
          expect(assigns(:posts).ids).to include post1_for_self.id
          expect(assigns(:posts).ids).not_to include draft1.id
        end

        it '所有文章權限為all' do
          expect(assigns(:posts).ids).to include post1.id
          expect(assigns(:posts).ids).to include post3.id
          expect(assigns(:posts).ids).to include post3.id
          expect(assigns(:posts).ids).not_to include post2_for_self.id
          expect(assigns(:posts).ids).not_to include post3_for_friend.id
        end

        it '朋友文章權限為friend' do
          expect(assigns(:posts).ids).to include post2_for_friend.id
          expect(assigns(:posts).ids).not_to include post3_for_friend.id
        end
      end
    end
  end

  context '#create' do
    before do
      user1
      sign_in(user1)

    end
    context 'Post' do
      before do
        post '/posts', params: { post: { title: 'title', content: 'content' } }
      end
      describe 'when successfully save' do
        it 'will redirect to show' do
          expect(response).to have_http_status(302)
          expect(response).to redirect_to('/posts/1')
        end

        it 'will create current users post' do
          expect(Post.last.user).to eq user1
        end
      end

      describe 'when failed' do
        xit 'will render to new' do
          expect(response).to render_template(:new)
        end
      end
    end

    context 'Draft' do
      before do
        post '/posts', params: { post: { title: 'title', content: 'draft' }, commit: "Save Draft" }
      end
      describe 'when successfully save' do
        it 'will redirect to users#drafts' do
          expect(response).to have_http_status(302)
          expect(response).to redirect_to('/users/1/drafts')
        end

        it 'will create current users draft' do
          expect(Post.last.user).to eq user1
        end
      end

      describe 'when failed' do
        xit 'will render to new' do
          expect(response).to render_template(:new)
        end
      end
    end
  end

  context '#show' do
    before do
      user1
      user2
      user3
      post2
      post2_for_self
      post2_for_friend
      post3_for_friend
      comment2_by_user1
      comment2_by_user2
      comment2_by_user3
      Friendship.create(user: user1, friend: user2, status: true)
    end
    describe '使用者未登入' do
      it '導向登入畫面' do
        get post_path(post2)
        expect(response).to redirect_to(new_user_session_path)
        expect(response).to have_http_status(302)
      end
    end

    describe '使用者登入' do
      before do
        sign_in(user1)
      end

      describe '文章權限' do
        it '朋友的文章，權限friend，內容可看見' do
          get post_path(post2_for_friend)
          expect(response).to render_template(:show)
          expect(assigns(:post)).to eq user2.posts.last
        end

        it '朋友的文章，權限myself，重新導向文章列表' do
          get post_path(post2_for_self)
          expect(response).to redirect_to(posts_path)
        end

        it '非好友的文章，權限為friend，重新導向文章列表' do
          get post_path(post3_for_friend)
          expect(response).to redirect_to(posts_path)
        end
      end

      describe '看見文章內容' do
        it '同時可以看見所有回覆內容' do
          get post_path(post2)
          expect(response).to render_template(:show)
          expect(assigns(:comments).count).to eq 3
        end
        it '增加觀看人數' do
          get post_path(post2)
          expect(Post.first.viewed_count).to eq 1
        end
      end
    end
  end

  context '#update' do
    before do
      user1
      post1
      draft1
      sign_in(user1)
    end
    context '文章更新' do
      before do
        patch '/posts/1', params: { post: { title: 'title', content: 'content update' } }
      end
      describe 'when successfully save' do
        it 'will redirect to show' do
          expect(response).to have_http_status(302)
          expect(response).to redirect_to('/posts/1')
        end

        it 'will update post content' do
          expect(Post.first.content).to eq 'content update'
        end
      end

      describe 'when failed' do
        xit 'will render to new' do
          expect(response).to render_template(:edit)
        end
      end
    end
    context '文章改為草稿' do
      before do
        patch '/posts/1', params: { post: { title: 'save draft', content: 'content draft' }, commit: 'Save Draft' }
      end
      describe 'when successfully save' do
        it 'will redirect to users#drafts' do
          expect(response).to have_http_status(302)
          expect(response).to redirect_to('/users/1/drafts')
        end

        it 'will save draft' do
          expect(Post.first.title).to eq 'save draft'
          expect(Post.first.public).to eq false
        end
      end
    end
    context '草稿改為文章' do
      before do
        patch '/posts/2', params: { post: { title: 'Published', content: 'Post' } }
      end
      describe 'when successfully save' do
        it 'will redirect to show' do
          expect(response).to have_http_status(302)
          expect(response).to redirect_to('/posts/2')
        end

        it 'will Published Post' do
          expect(Post.last.content).to eq 'Post'
          expect(Post.last.public).to eq true
        end
      end
    end
    context '草稿更新內容' do
      before do
        patch '/posts/2', params: { post: { title: 'title', content: 'update draft' }, commit: 'Save Draft' }
      end
      describe 'when successfully save' do
        it 'will redirect to users#drafts' do
          expect(response).to have_http_status(302)
          expect(response).to redirect_to('/users/1/drafts')
        end

        it 'will update draft' do
          expect(Post.last.content).to eq 'update draft'
          expect(Post.last.public).to eq false
        end
      end
    end
  end

  context '#destroy' do
    before do
      user1
      user2
      post1
      post2
      sign_in(user1)
    end
    describe '使用者可以刪除' do
      it '自己的文章' do
        delete '/posts/1'
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(posts_path)
        expect(Post.count).to eq 1
      end
    end
    describe '使用者無法刪除' do
      it '其他人的文章' do
        delete '/posts/2'
        expect(response).to redirect_to(post_path(post2))
        expect(Post.count).to eq 2
      end
    end
  end

  context '#collect' do
    before do
      user1
      post1
      sign_in(user1)
      post '/posts/1/collect', xhr: true
    end

    describe 'collect first post' do
      it 'will save collections' do
        expect(user1.collections.count).to eq 1
        expect(user1.collections.first.post_id).to eq 1
      end
    end
  end

  context '#uncollect' do
    before do
      user1
      post1
      sign_in(user1)
      Collection.create(user_id: 1, post_id: 1)
      post '/posts/1/uncollect', xhr: true
    end

    it 'will delete collect' do
      expect(user1.collections.count).to eq 0
    end
  end
end