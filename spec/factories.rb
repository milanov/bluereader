require 'digest/sha1'

FactoryGirl.define do
  factory :user, class: Bluereader::User do
    username 'username'
    encrypted_password Digest::SHA1.hexdigest('password')
    full_name 'John Doe'
    logged_in_at Time.now.to_i
    logged_out_at 0
  end

  factory :category, class: Bluereader::Category do
    user
    name 'category'
  end

  factory :feed, class: Bluereader::Feed do
    user
    category
    name 'feed'
    url 'feed.url.com'
  end

  factory :news, class: Bluereader::News do
    user
    feed
    title 'news item'
    description 'description'
    url 'news.url.com'
    read false
    date Time.now.to_i
  end

  factory :setting, class: Bluereader::Setting do
    user
    delete_after_days 0
  end
end