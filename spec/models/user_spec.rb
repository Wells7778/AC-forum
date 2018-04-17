RSpec.describe 'Post', type: :model do
  let!(:user1) { create(:user, email: FFaker::Internet.email, role: "admin") }
  let!(:user2) { create(:user, email: FFaker::Internet.email) }
  let!(:user3) { create(:user, email: FFaker::Internet.email) }
  let!(:user4) { create(:user, email: FFaker::Internet.email) }
  context '#admin?' do
    it 'user1 is admin' do
      expect(user1.admin?).to eq true
      expect(user2.admin?).to eq false
    end
  end

  context '#friend?(user)' do
    before do
      Friendship.create(user: user1, friend: user2, status: true)
      Friendship.create(user: user2, friend: user3, status: true)
      Friendship.create(user: user3, friend: user4)
    end
    it 'user1 and user2 is friend' do
      expect(user1.friend?(user2)).to eq true
    end

    it 'user1 and user3 isn\'t friend' do
      expect(user1.friend?(user3)).to eq false
    end

    it 'user2 and user3 is friend' do
      expect(user3.friend?(user2)).to eq true
    end
    it 'user4 and user3 isn\'t friend' do
      expect(user3.friend?(user4)).to eq false
    end
  end

  context '#not_yet_accepted_by?(user)' do
    describe 'user1邀請user2' do
      before do
        Friendship.create(user: user1, friend: user2)
      end
      it 'user2沒有未被接受好友' do
        expect(user2.not_yet_accepted_by?(user1)).to eq false
      end

      it 'user1有未被接受好友' do
        expect(user1.not_yet_accepted_by?(user2)).to eq true
      end
    end
  end

  context '#not_yet_responded_to?(user)' do
    describe 'user1邀請user2' do
      before do
        Friendship.create(user: user1, friend: user2)
      end
      it 'user1沒有未回覆交友請求' do
        expect(user1.not_yet_responded_to?(user2)).to eq false
      end

      it 'user2有未回覆交友請求' do
        expect(user2.not_yet_responded_to?(user1)).to eq true
      end
    end
  end

  context '#all_friends' do
    before do
      Friendship.create(user: user1, friend: user2, status: true)
      Friendship.create(user: user2, friend: user3, status: true)
      Friendship.create(user: user3, friend: user4)
      Friendship.create(user: user4, friend: user1, status: true)
    end
    it 'user1 好友清單' do
      expect(user1.all_friends).to eq [user2, user4]
    end
    it 'user3 好友清單' do
      expect(user3.all_friends).to eq [user2]
    end
  end
end