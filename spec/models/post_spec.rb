RSpec.describe 'Post', type: :model do
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
  context '#readable_posts' do
    before do
      user1
      user2
      user3
      Friendship.create(user: user1, friend: user2, status: true)
      post1
      post1_for_self
      post1_for_friend
      post2
      post2_for_friend
      post2_for_self
      post3_for_friend
    end
    describe 'user1' do
      it 'all readable posts' do
        post = Post.readable_posts(user1)
        expect(post).to eq [post1, post1_for_self, post1_for_friend, post2, post2_for_friend]
      end
    end
    describe 'user2' do
      it 'all readable posts' do
        post = Post.readable_posts(user2)
        expect(post).to eq [post1, post1_for_friend, post2, post2_for_friend, post2_for_self]
      end
    end
    describe 'user3' do
      it 'all readable posts' do
        post = Post.readable_posts(user3)
        expect(post).to eq [post1, post2, post3_for_friend]
      end
    end
  end

  context '#viewed_by?' do
    before do
      user1
      user2
      post1
      Viewed.create(user: user1, post: post1)
    end
    it 'viewed_by user1 will be true' do
      expect(post1.viewed_by?(user1)).to eq true
    end
    it 'viewed_by user2 will be false' do
      expect(post1.viewed_by?(user2)).to eq false
    end
  end

  context '#collect_by?' do
    before do
      user1
      user2
      post1
      Collection.create(user: user1, post: post1)
    end
    it 'collect_by user1 will be true' do
      expect(post1.collect_by?(user1)).to eq true
    end
    it 'collect_by user2 will be false' do
      expect(post1.collect_by?(user2)).to eq false
    end
  end

  context '#check_authority_for' do
    before do |variable|
      user1
      user2
      user3
      Friendship.create(user: user1, friend: user2, status: true)
      post1
      post1_for_self
      post1_for_friend
      post2
      post2_for_friend
      post2_for_self
      post3_for_friend
    end
    it 'post1 for user1' do
      expect(post1.check_authority_for?(user1)).to eq true
    end
    it 'post1_for_friend for user1' do
      expect(post1_for_friend.check_authority_for?(user1)).to eq true
    end
    it 'post1_for_self for user1' do
      expect(post1_for_self.check_authority_for?(user1)).to eq true
    end
    it 'post2 for user1' do
      expect(post2.check_authority_for?(user1)).to eq true
    end
    it 'post2_for_friend for user1' do
      expect(post2_for_friend.check_authority_for?(user1)).to eq true
    end
    it 'post2_for_self for user1' do
      expect(post2_for_self.check_authority_for?(user1)).to eq false
    end
    it 'post3 for user1' do
      expect(post3_for_friend.check_authority_for?(user1)).to eq false
    end
  end
end
