require 'spec_helper'

module Bluereader
  describe Feed do
    describe 'validate_add_feed' do
      it 'does not allow a feed with an empty name to be added ' do
        Feed.validate_add_feed('').should eq "Feed url can't be empty."
      end

      it 'does not add a feed with the same url more than once' do
        logged_user = FactoryGirl.create(:user)
        category = FactoryGirl.create(:category, :name => 'Sports', :user_id => logged_user.id)
        FactoryGirl.create(:feed, :user_id => logged_user.id, :category_id => category.id)

        Feed.validate_add_feed('feed.url.com').should eq 'You already have a feed with the same url.'
      end

      it 'returns an empty string if the feed is valid' do
        FactoryGirl.create(:user)

        Feed.validate_add_feed('Sports').should be_empty
      end
    end

    describe 'add_feed' do
      it "adds the feed to the current user's feeds" do
        logged_user = FactoryGirl.create(:user)
        category = FactoryGirl.create(:category, :user_id => logged_user.id)
        Feed.stub(:feed_title) { 'Feed Title' }
        News.stub(:insert_news_if_necessary)

        expect do
          Feed.add_feed('feed.url.com', category.id)
        end.to change(Feed, :count).by(1)
      end
    end

    describe 'delete_feed' do
      it 'deletes a feed that belongs to the currently logged user' do
        logged_user = FactoryGirl.create(:user)
        category = FactoryGirl.create(:category, :name => 'Sports', :user_id => logged_user.id)
        feed = FactoryGirl.create(:feed, :user_id => logged_user.id, :category_id => category.id)

        expect do
          Feed.delete_feed(feed.id)
        end.to change(Feed, :count).by(-1)
      end
    end

    describe 'feeds_for_category' do
      it 'return an empty hash if the given category does not have any feeds' do
        logged_user = FactoryGirl.create(:user)
        category = FactoryGirl.create(:category, :name => 'Sports', :user_id => logged_user.id)

        Feed.feeds_for_category(category.id).should be_empty
      end

      it 'returns a hash with the right ids and names for all feeds for a given category' do
        user = FactoryGirl.create(:user)
        category = FactoryGirl.create(:category, :name => 'Sports', :user_id => user.id)
        football = FactoryGirl.create(:feed, :name => 'Football', :user_id => user.id, :category_id => category.id)
        basketball = FactoryGirl.create(:feed, :name => 'Basketball', :user_id => user.id, :category_id => category.id)
        user.update_attributes({:logged_out_at => Time.now.to_i})

        logged_user = FactoryGirl.create(:user)
        tennis = FactoryGirl.create(:feed, :name => 'Tennis', :user_id => logged_user.id, :category_id => category.id)
        Feed.feeds_for_category(category.id).should eq({football.id => 'Football',
                                                        basketball.id => 'Basketball',
                                                        tennis.id => 'Tennis'})
      end
    end

    describe 'feeds_list' do
      it 'returns a hash with the right ids and names for all feeds for the  currently logged user' do
        user = FactoryGirl.create(:user)
        category = FactoryGirl.create(:category, :name => 'Sports', :user_id => user.id)
        FactoryGirl.create(:feed, :name => 'Basketball', :user_id => user.id, :category_id => category.id)
        user.update_attributes({:logged_out_at => Time.now.to_i})

        logged_user = FactoryGirl.create(:user)
        tennis = FactoryGirl.create(:feed, :name => 'Tennis', :user_id => logged_user.id, :category_id => category.id)
        football = FactoryGirl.create(:feed, :name => 'Football', :user_id => logged_user.id, :category_id => category.id)

        Feed.feeds_list.should eq({tennis.id => 'Tennis',
                                   football.id => 'Football'})
      end
    end

    describe 'first_feed_id' do
      it 'returns the id of the feed with the lowest id for the currently logged user' do
        user = FactoryGirl.create(:user)
        category = FactoryGirl.create(:category, :name => 'Sports', :user_id => user.id)
        FactoryGirl.create(:feed, :name => 'Basketball', :user_id => user.id, :category_id => category.id)
        user.update_attributes({:logged_out_at => Time.now.to_i})

        logged_user = FactoryGirl.create(:user)
        FactoryGirl.create(:feed, :id => 123, :name => 'Tennis', :user_id => logged_user.id, :category_id => category.id)
        football = FactoryGirl.create(:feed, :id => 12, :name => 'Football', :user_id => logged_user.id, :category_id => category.id)

        Feed.first_feed_id.should eq football.id
      end
    end

    describe 'change_feeds_categories' do
      it 'changes the category of all feeds that belong to an old category with a new one ' do
        logged_user = FactoryGirl.create(:user)
        sports = FactoryGirl.create(:category, :name => 'Sports', :user_id => logged_user.id)
        movies = FactoryGirl.create(:category, :name => 'Movies', :user_id => logged_user.id)

        FactoryGirl.create(:feed, :user_id => logged_user.id, :category_id => movies.id)
        FactoryGirl.create(:feed, :user_id => logged_user.id, :category_id => movies.id)

        Feed.change_feeds_categories(movies.id, sports.id)

        Feed.where(:user_id => logged_user.id, :category_id => sports.id).count.should eq 2
      end
    end

    describe 'change_feed_category' do
      it 'changes the category of a given feed with a new one ' do
        logged_user = FactoryGirl.create(:user)

        feed = FactoryGirl.create(:feed, :user_id => logged_user.id, :category_id => 1)

        Feed.change_feed_category(feed.id, 123)

        Feed.find(feed.id).category_id.should eq 123
      end
    end

    describe 'id_from_url' do
      it 'return the id the feed with the given url' do
        logged_user = FactoryGirl.create(:user)
        FactoryGirl.create(:feed, :id => 7, :user_id => logged_user.id, :category_id => 1, :url => 'url.com')
        FactoryGirl.create(:feed, :id => 123, :user_id => logged_user.id, :category_id => 1)

        Feed.id_from_url('url.com').should eq 7
      end
    end
  end
end