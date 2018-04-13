namespace :dev do
  task fake_post: :environment do
    Post.destroy_all

    100.times do
      user = User.all.sample
      post = user.posts.build(
        title: FFaker::Book.unique.author,
        content: FFaker::Book.description,
        image: File.open(Rails.root.join("public/fake_image/#{rand(1..12)}.jpg")),
        draft: [true, false].sample,
        authority: ["Myself", "Friend", "All"].sample
      )
      post.save
      post.categories_posts.create(category: Category.all.sample)
    end
    puts "have created fake posts"
    puts "now you have #{Post.count} posts data"
  end

  task fake_user: :environment do
    User.where.not(role: "ADMIN").destroy_all
    20.times do
      username = FFaker::Name.unique.last_name
      User.create!(
        name: username,
        email: "#{username}@example.com",
        password: "12345678",
        avatar: File.open(Rails.root.join("public/fake_avatar/user#{rand(1..20)}.jpg")),
        description: FFaker::Lorem.paragraphs
      )
    end
    puts "created fake users"
    puts "now you have #{User.count} users data"
  end

  task fake_comment: :environment do
    500.times do
      post = Post.open_public.sample
      user = User.all.sample
      post.comments.create!(
        user: user,
        content: FFaker::Lorem.sentence
      )
      post.vieweds.create( user: user )
    end
    puts "created fake comments"
    puts "now you have #{Comment.count} comments data"
  end

  task fake_collect: :environment do
    100.times do
      user = User.all.sample
      post = Post.open_public.sample
      if post.allow_user(user)
        post.collections.create(user: user)
      end
    end
    puts "created fake collections"
    puts "now you have #{Collection.count} collections data"
  end

  task fake_friend: :environment do
    60.times do
      user1 = User.all.sample
      user2 = User.where.not(id: user1.id).sample
      unless user1.unconfirm_friend?(user2) || user1.has_no_request?(user2)
        user1.unconfirm_friendships.create!(friend: user2)
        puts "#{user1.name} invite #{user2.name}"
      end
    end
    30.times do
      friendship = Friendship.where(status: false).sample
      friendship.update(status: true)
      puts "#{friendship.user_id} accept friend to #{friendship.friend_id}"
    end
  end
end