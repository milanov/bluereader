require 'lib/bluereader/ui/main/panels/right_panel'
require 'lib/bluereader/core/categories'

module Bluereader
  class LeftPanel < Wx::TreeCtrl
    def initialize(parent, top_window)
      id_tree = 1
      @top_window = top_window

      # Initialize the TreeCtrl contol
      super(parent, id_tree, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::TR_HIDE_ROOT)

      # Set the background colour to a light blue
      set_background_colour(Wx::Colour.new(210, 225, 230))

      # Set the font to bold arial
      set_font(Wx::Font.new(9, Wx::SWISS, Wx::NORMAL, Wx::BOLD, 0, 'Arial'))

      # Generate the categories tree
      generate_categories_list

      # Handle the click on a tree element
      evt_tree_item_activated(id_tree, :feed_selected)

      # Expand all the elements in the tree
      expand_all

      refresh
      self
    end

    def generate_categories_list
      # Remove the current elements
      delete_all_items

      # Add a 'fake' root element, which is needed but will be invisible
      root = add_root('');


      categories = Category.current_user_categories
      categories_ids = categories.keys

      # Marks if any feed exist so that later it can be selected
      item_to_select = nil

      categories_ids.each do |category_id|
        # Add the category name as a parent item
        category_name = categories[category_id];
        category_name_tree = append_item(root, category_name)

        Feed.feeds_for_category(category_id).each do |feed_id, feed_name|
          # Get the number of unread news for the current feed
          unread_news = News.unread_feed_news_count(feed_id);

          # Add this number to the feed name if there are unread news
          name = feed_name
          name += " (#{unread_news})" unless unread_news.zero?

          # Add the feed to its parent item (its category)
          feed_entry = append_item(category_name_tree, feed_name, -1, -1, feed_id)

          # Initialize which feed will be selected by default
          item_to_select = feed_entry if item_to_select.nil?
        end
      end

      # If any feed exists, select the first one
      select_item(item_to_select) unless item_to_select.nil?
    end

    def feed_selected
      # Get the itemdata of the clicked tree item
      feed_id = get_item_data(selection)

      unless feed_id.nil?
        # Get the news for the selected feed and show them in the right panel
        news_for_feed = News.news_for_feed(feed_id)
        @top_window.right_panel.generate_news_list(news_for_feed)
      end
    end
  end
end