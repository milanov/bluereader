module Bluereader
  class Feed < ActiveRecord::Base
    belongs_to :user
    belongs_to :category
    has_many :news

    class << self
      # Validates the input for the `add_category` method. Returns a message
      # with the validation error if there is any, and an empty string otherwise.
      def validate_add_feed(url)
        if url.empty?
          validation_message = "Feed url can't be empty."
        elsif exists?(:url => url, :user_id => User.current_user_id)
          validation_message = 'You already have a feed with the same url.'
        end

        validation_message or ''
      end

      # First, tries to parse the feed to get its title. If it succeeds, the
      # feed is added, belonging to its category and the currently logged user.
      def add_feed(url, category_id)
        feed_name = feed_title(url)

        unless feed_name.empty?
          create(:user_id => User.current_user_id,
                 :category_id => category_id,
                 :name => feed_name, :url => url)

          News.insert_news_if_necessary(url)
        end
      end

      # Deletes a feed, which belongs to the currently logged user.
      def delete_feed(id)
        destroy(id)
      end

      # Returns a hash of all the feeds that belong to a given category in the
      # form of {feed_id => feed_name, ...}.
      def feeds_for_category(category_id)
        feeds = {}

        where(:category_id => category_id).each do |feed|
          feeds[feed['id']] = feed['name']
        end

        feeds
      end

      # Returns a hash of all the feeds that belong to the currently logged user
      # in the form of {feed_id => feed_name, ...}.
      def feeds_list
        feeds = {}

        where(:user_id => User.current_user_id).each do |feed|
          feeds[feed['id']] = feed['name']
        end

        feeds
      end

      # Returns the id of the feed with the lowest id (the oldest feed) that belong
      # to the currenlty logged user, and 0 if the user doesn't have any feeds added.
      def first_feed_id
        feed = where(:user_id => User.current_user_id).first
        feed.nil? ? 0 : feed.id
      end

      # Makes all feeds belonging to the category with id category_id belong to the one
      # with id new_category_id.
      def change_feeds_categories(category_id, new_category_id)
        where(["category_id = ?", category_id]).update_all(:category_id => new_category_id)
      end

      # Changes the category of a feed to another given category.
      def change_feed_category(feed_id, category_id)
        update(feed_id, :category_id => category_id)
      end

      # Returns the id of the feed with the given url, which belongs to the currently logged user,
      # and 0 if there is no feed with that url.
      def id_from_url(url)
        feed = where(:user_id => User.current_user_id, :url => url).first
        feed.nil? ? 0 : feed.id
      end

      private
      # Returns the title of a given feed after pasing it, and an empty string if
      # something had gone wrong.
      def feed_title(url)
        parsed_feed = Arss::FeedParser.parse_uri(url)

        parsed_feed.feed['channel'].has_key?('title') ? parsed_feed.feed['channel']['title'] : ''
      end
    end
  end
end