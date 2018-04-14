FactoryBot.define do
  factory :post do
    title FFaker::Book.unique.author
    content FFaker::Book.description
    user
    public true

    factory :draft do
      public false
    end

    factory :post_for_all do
      authority "all"
    end

    factory :post_for_friend do
      authority "friend"
    end

    factory :post_for_self do
      authority "myself"
    end
  end

  factory :comment do
    content "content"
    user
    post
  end

  factory :collection do
    user
    post
  end

  factory :view do
    user
    post
  end

  factory :user do
    name FFaker::Name.unique.last_name
    email FFaker::Internet.email
    password "12345678"

    factory :admin do
      role "admin"
    end
  end
end
