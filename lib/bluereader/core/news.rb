module Bluereader
  class News < ActiveRecord::Base
    belongs_to :user
    belongs_to :feed

    class << self
      # Deletes all the news that belong to the currently logged user and are older than a
      # specified time, which we get from the Settings model.
      def delete_old_news_if_necessary
        unless Setting.keep_news_time.zero?
          user_id = User.current_user_id
          date_limit = Setting.keep_news_time

          where(["user_id = ? AND date < ?", user_id, date_limit]).destroy_all
        end
      end

      # Inserts the news from a given feed, but only if they are newer than the latest news
      # added for that feed. The news should also be newer than the current time - the days we
      # have specified for the news to be saved.
      # For example, if keep_news_time is set to 1 day, only news from today would be added.
      def insert_news_if_necessary(url)
        latest_date = latest_news_date(Feed.id_from_url(url))
        latest_date = Setting.keep_news_time if latest_date.zero?

        channel = Arss::FeedParser.parse_uri(url).feed['channel']
        return unless channel.has_key? 'items'

        channel['items'].each do |item|
          if Setting.get_delete_after_days.nonzero?
            next if (item['pubDate'] <= latest_date or item['pubDate'] < Setting.keep_news_time)
          end

          create(:user_id => User.current_user_id, :feed_id => Feed.id_from_url(url),
                 :title => item['title'], :description => item['description'],
                 :url => item['link'], :read => 0, :date => item['pubDate'])
        end
      end

      # Returns a list of hashes, where each is a single news item that belongs
      # to the given feed.
      def news_for_feed(feed_id)
        news = []

        where(:user_id => User.current_user_id, :feed_id => feed_id).each do |news_item|
          news.push news_item.attributes
        end

        news
      end

      # Marks a single news item that belongs to the currently logged user as read.
      def read_news_item(url)
        where(:user_id => User.current_user_id, :url => url).update_all(:read => true)
      end

      # Marks all the news that belong to the currently logged user as read.
      def mark_all_news_as_read
        where(:user_id => User.current_user_id).update_all(:read => 1)
      end

      # Returns the number of unread news for a given feed.
      def unread_feed_news_count(feed_id)
        count(:all, :conditions => ["feed_id = ? AND user_id = ? AND read = ?",
                                    feed_id, User.current_user_id, false])
      end

      # Searches in all the news that belong to the current user. The phrase is searched in
      # both the title and the description of every news item.
      # Returns a list of hashesh, each containg the data for a single news item.
      def search_in_news(phrase)
        news = []

        where(["user_id = ? AND (description LIKE ? OR title LIKE ?)",
                User.current_user_id, "%#{phrase}%", "%#{phrase}%"]).each do |news_item|
          news.push news_item.attributes
        end

        news
      end

      # Returns the date of the most recently added news for a given feed.
      def latest_news_date(feed_id)
        current_user_id = User.current_user_id
        news_item = find(:first,
                         :conditions => [ "user_id = ? AND feed_id = ?", current_user_id, feed_id],
                         :order => "date DESC")
        news_item.nil? ? 0 : news_item.date
      end
    end
  end
end