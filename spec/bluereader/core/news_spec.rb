module Bluereader
  describe News do
    describe 'delete_old_news_if_necessary' do
      it 'does not remove any news if the keep news time is zero' do
        Setting.stub(:keep_news_time) { 0 }

        expect do
          News.delete_old_news_if_necessary
        end.to change(News, :count).by(0)
      end

      it 'removes all the news that have an older date the the keep news time' do
        Setting.stub(:keep_news_time) { 1000000000000000 }

        logged_user = FactoryGirl.create(:user)
        feed = FactoryGirl.create(:feed, :user_id => logged_user.id, :category_id => 1)
        FactoryGirl.create(:news, :user_id => logged_user.id, :feed_id => feed.id)
        FactoryGirl.create(:news, :user_id => logged_user.id, :feed_id => feed.id)

        expect do
          News.delete_old_news_if_necessary
        end.to change(News, :count).by(-2)
      end
    end

    describe 'insert_news_if_necessary' do
      it 'does not add any news if the url(file) is not a valid resource' do
        logged_user = FactoryGirl.create(:user)
        FactoryGirl.create(:setting, :user_id => logged_user.id)

        expect do
          News.insert_news_if_necessary('non-existing-resource')
        end.to change(News, :count).by(0)
      end

      it 'adds the news to their feed, which belongs to the currently logged user' do
        logged_user = FactoryGirl.create(:user)
        setting = FactoryGirl.create(:setting, :user_id => logged_user.id)

        expect do
          News.insert_news_if_necessary(File.dirname(__FILE__) + '/resources/feed.rss')
        end.to change(News, :count).by(2)
      end
    end

    describe 'news_for_feed' do
      it 'returns a list of hashes containing all the data of the news that belong to given feed' do
        logged_user = FactoryGirl.create(:user)
        feed = FactoryGirl.create(:feed, :user_id => logged_user.id, :category_id => 1)
        first_news = FactoryGirl.create(:news, :user_id => logged_user.id, :feed_id => feed.id)
        second_news = FactoryGirl.create(:news, :user_id => logged_user.id, :feed_id => feed.id)
        FactoryGirl.create(:news, :user_id => logged_user.id, :feed_id => 1234567)

        News.news_for_feed(feed.id).should eq [first_news.attributes, second_news.attributes]
      end
    end

    describe 'read_news_item' do
      it 'marks a news with a given url as read' do
        logged_user = FactoryGirl.create(:user)
        news_item = FactoryGirl.create(:news, :user_id => logged_user.id, :feed_id => 1, :url => 'news.url.com')
        News.read_news_item('news.url.com')

        News.find(news_item.id).read.should be_true
      end
    end

    describe 'mark_all_news_as_read' do
      it 'marks all news that belong to the currently logged user as read' do
        logged_user = FactoryGirl.create(:user)
        FactoryGirl.create(:news, :user_id => logged_user.id, :feed_id => 1, :read => 1)
        FactoryGirl.create(:news, :user_id => logged_user.id, :feed_id => 1)
        News.mark_all_news_as_read

        News.where(:user_id => logged_user.id, :read => 1).count.should eq 2
      end
    end

    describe 'unread_feed_news_count' do
      it 'returns the number of unread news that belong to a given feed' do
        logged_user = FactoryGirl.create(:user)
        FactoryGirl.create(:news, :user_id => logged_user.id, :feed_id => 1, :read => 1)
        FactoryGirl.create(:news, :user_id => logged_user.id, :feed_id => 1)

        News.unread_feed_news_count(1).should eq 1
      end
    end

    describe 'search_in_news' do
      it 'returns a list of hashes with the attributes of the found news' do
        logged_user = FactoryGirl.create(:user)
        first_news = FactoryGirl.create(:news, :user_id => logged_user.id, :feed_id => 1, :title => 'Please find me.')
        second_news = FactoryGirl.create(:news, :user_id => logged_user.id, :feed_id => 1, :description => 'Remember it.')
        FactoryGirl.create(:news, :user_id => logged_user.id, :feed_id => 1)

        News.search_in_news('me').should eq [first_news.attributes, second_news.attributes]
      end
    end

    describe 'latest_news_date' do
      it 'returns the date of the most recently added news for a given feed that belongs to the current user' do
        logged_user = FactoryGirl.create(:user)
        FactoryGirl.create(:news, :user_id => logged_user.id, :feed_id => 1, :date => 10000)
        FactoryGirl.create(:news, :user_id => logged_user.id, :feed_id => 1, :date => 10)

        News.latest_news_date(1).should eq 10000
      end

      it 'returns 0 if there are no news added for that feed' do
        logged_user = FactoryGirl.create(:user)
        FactoryGirl.create(:news, :user_id => logged_user.id, :feed_id => 1)
        FactoryGirl.create(:news, :user_id => logged_user.id, :feed_id => 1)

        News.latest_news_date(123).should be_zero
      end
    end
  end
end