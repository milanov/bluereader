module Bluereader
  class Category < ActiveRecord::Base
    belongs_to :users
    has_many :feeds, :dependent => :destroy

    class << self
      # Validates the input for the `add_category` method. Returns a message
      # with the validation error if there is any, and an empty string otherwise.
      def validate_add_category(name)
        if name.empty?
          validation_message =  "Category name can't be empty."
        elsif exists?(:name => name, :user_id => User.current_user_id)
          validation_message = 'You already have a category with the same name.'
        end

        validation_message or ''
      end

      # Adds a category that belongs to the currently logged user.
      def add_category(name)
        create(:user_id => User.current_user_id, :name => name)
      end

      # Deletes a category, which belongs to the currently logged user, and transfers
      # its feeds to the 'General' category.
      def delete_category(id)
        delete(id)

        Feed.change_feeds_categories(id, general_category_id)
      end

      # Returns a hash of all categories, which belong to the currently logged
      # user, in the form of {category_id => category_name, ...}
      def current_user_categories
        categories = {}
        where(:user_id => User.current_user_id).each do |category|
          categories[category['id']] = category['name']
        end

        categories
      end

      # Returns the id of a given category, which belongs to the currently logged user.
      def id_from_name(category_name)
        where(:user_id => User.current_user_id, :name => category_name).first.id
      end

      # Returns the id of the 'General' category for the current user.
      def general_category_id
        where(:name => 'General', :user_id => User.current_user_id).first.id
      end

    end
  end
end