RSpec.describe 'Comment', type: :request do
  let(:user1) { create(:user, email: FFaker::Internet.email) }
  let(:post1) { create(:post, user: user1)}
  let(:comment1_by_user2) { create(:comment, user: user2, post: post1)}

  let(:user2) { create(:user, email: FFaker::Internet.email) }
  let(:post2) { create(:post, user: user2)}
  let(:post2_for_self) { create(:post_for_self, user: user2) }
  let(:comment2_by_user1) { create(:comment, user: user1, post: post2)}

  context '#create' do
    context '有權限的文章' do
      before do
        user1
        post1
        post2
        sign_in(user1)
      end
      describe '自己文章送出評論' do
        before do
          post '/posts/1/comments', params: { comment: { content: 'title' } }
        end
        it '新增成功導向文章內容頁' do
          expect(response).to have_http_status(302)
          expect(response).to redirect_to('/posts/1')
        end

        it '建立一則新評論' do
          expect(Comment.last.user).to eq user1
          expect(post1.comments.count).to eq 1
        end
      end
      describe '別人文章送出評論' do
        before do
          post '/posts/2/comments', params: { comment: { content: 'title' } }
        end
        it '新增成功導向文章內容頁' do
          expect(response).to have_http_status(302)
          expect(response).to redirect_to('/posts/2')
        end

        it '建立一則新評論' do
          expect(Comment.last.user).to eq user1
          expect(post2.comments.count).to eq 1
        end
      end
    end

    context '沒有權限的文章' do
      before do
        user1
        user2
        post2_for_self
        sign_in(user1)
      end
      describe '送出評論' do
        before do
          post '/posts/1/comments', params: { comment: { content: 'title' } }
        end
        it '無法留下評論，導向文章列表' do
          expect(response).to have_http_status(302)
          expect(response).to redirect_to('/posts')
        end

        it '無法新增評論' do
          expect(post2_for_self.comments.count).to eq 0
        end
      end
    end
  end

  context '#destroy' do
    context '別人的評論' do
      before do
        user1
        user2
        post1
        comment1_by_user2
        sign_in(user1)
      end
      describe '送出刪除請求' do
        before do
          delete '/posts/1/comments/1'
        end
        it '無法刪除導向文章內容頁' do
          expect(response).to have_http_status(302)
          expect(response).to redirect_to('/posts/1')
        end
        it '無法刪除評論' do
          expect(Comment.last.user).to eq user2
          expect(post1.comments.count).to eq 1
        end
      end
    end

    context '自己的評論' do
      before do
        user1
        user2
        post2
        comment2_by_user1
        sign_in(user1)
      end
      describe '送出刪除請求' do
        before do
          delete '/posts/1/comments/1'
        end
        it '成功刪除導向文章內容頁' do
          expect(response).to have_http_status(302)
          expect(response).to redirect_to('/posts/1')
        end
        it '成功刪除評論' do
          expect(post1.comments.count).to eq 0
        end
      end
    end
  end
end

