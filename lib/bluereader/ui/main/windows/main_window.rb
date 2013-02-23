require 'lib/bluereader/ui/main/panels/left_panel'
require 'lib/bluereader/ui/main/panels/right_panel'
require 'lib/bluereader/ui/main/windows/splitter_window'
require 'lib/bluereader/ui/main/windows/add_feed_window'
require 'lib/bluereader/ui/main/windows/change_feed_category_window'
require 'lib/bluereader/ui/main/windows/settings_window'

module Bluereader
  class MainWindow < Wx::Frame
    attr_reader :left_panel, :right_panel

    def initialize(parent, id, title, position, size)
      super

      id_search, id_mark_news, id_add_feed, id_delete_feed, id_change_feed_category = (0..4).to_a
      id_add_category, id_delete_category, id_settings, id_logout, id_delete_account = (5..9).to_a

      # News submenu
      news = Wx::Menu.new
      news.append(id_search, "Search news\tCtrl+F")
      news.append_separator
      news.append(id_mark_news, "Mark all news as read\tCtrl+M")

      # Feeds submenu
      feeds = Wx::Menu.new
      feeds.append(id_add_feed, "Add feed\tCtrl+A")
      feeds.append_separator
      feeds.append(id_delete_feed, "Delete feed\tCtrl+D")
      feeds.append_separator
      feeds.append(id_change_feed_category, "Change feed's category")

      # Categories submenu
      categories = Wx::Menu.new
      categories.append(id_add_category, "Add category")
      categories.append_separator
      categories.append(id_delete_category, "Delete category")

      # Options submenu
      options = Wx::Menu.new
      options.append(id_settings, "Settings\tCtrl+S")
      options.append(Wx::ID_ABOUT, 'About')
      options.append(id_delete_account, "delete_account!")

      # Exit submenu
      exit = Wx::Menu.new
      exit.append(id_logout, "Logout\tCtrl+L")
      exit.append(Wx::ID_EXIT, "Exit\tCtrl+X")

      # Create the menu bar
      menubar = Wx::MenuBar.new
      menubar.append(news, "News")
      menubar.append(feeds, "Feeds")
      menubar.append(categories, "Categories")
      menubar.append(options, "Options")
      menubar.append(exit, "Exit")

      # Attach the menubar to the window
      self.menu_bar = menubar

      # Set a status bar
      create_status_bar(4)

      # Set the date and the currently logged user
      today = Time.now.strftime("%A, %m.%d.%Y")
      set_status_text("Logged as: #{User.current_user_name}", 2)
      set_status_text(today, 3)


      # Split the window into two subwindows
      splitter = SplitterWindow.new(self, Wx::ID_ANY)

      # Initialize the two subwindows with the left and right panels
      @left_panel = LeftPanel.new(splitter, self)
      @right_panel = RightPanel.new(splitter, self)
      splitter.init(@left_panel)
      splitter.init(@right_panel)

      left_panel_minimum_size = 180

      # Set the minimum panel size for the left panel and split the main window
      splitter.minimum_pane_size = left_panel_minimum_size
      splitter.split_vertically(@left_panel, @right_panel, left_panel_minimum_size)


      # Handle clicks on the menu items
      evt_menu(id_search, :search_in_news)
      evt_menu(id_mark_news, :mark_as_read)
      evt_menu(id_add_feed, :add_feed)
      evt_menu(id_delete_feed, :delete_feed)
      evt_menu(id_change_feed_category, :change_feed_category)
      evt_menu(id_add_category, :add_category)
      evt_menu(id_delete_category, :delete_category)
      evt_menu(id_delete_account, :delete_account)
      evt_menu(id_settings, :update_settings)
      evt_menu(Wx::ID_ABOUT, :display_about)
      evt_menu(id_logout, :logout)
      evt_menu(Wx::ID_EXIT, :close_window)


      self
    end

    def search_in_news
      # Create the dialog box
      dialog = Wx::TextEntryDialog.new(self, 'What to search for:', 'Search in all news')

      # If the user clicked okay and not cancel do the search and display the results
      if dialog.show_modal == Wx::ID_OK
        phrase = dialog.get_value

        # Get the news the match the search and show them in the right panel
        found_news = News.search_in_news(phrase)
        @right_panel.generate_news_list(found_news)
      end
    end

    def mark_as_read
      # Mark all the news as read
      News.mark_all_news_as_read

      # Refresh the left panel so that the nubmers of read news are updated
      @left_panel.generate_categories_list

      # Refresh the right panel so that the read news are no longer showed in bold
      @right_panel.generate_first_feeds_news
    end

    def add_feed
      # Create the add feed window and wait for a user action
      add_feed_window = AddFeedWindow.new(self, Wx::ID_ANY, 'Add feed', self)
      add_feed_window.centre
      add_feed_window.show_modal
    end

    def delete_feed
      # Get the feeds
      feeds = Feed.feeds_list

      # Sort the feeds by id, e.g the last is the one that was added last
      feeds_names = feeds.values

      # Create the dialog from which the user will choose which feed to delete
      feed_deletion = Wx::SingleChoiceDialog.new(self, 'Select a feed to be deleted:', 'Delete feed', feeds_names)

      # If the user clicked okay and not cancel do the deletion
      if feed_deletion.show_modal == Wx::ID_OK
        feed_name = feed_deletion.get_selection_client_data

        # Delete the feed and update both the categories and feeds list and the news
        Feed.delete_feed(feed_id) unless feed_id.nil?
        @left_panel.generate_categories_list
        @right_panel.generate_first_feeds_news
      end
    end

    def change_feed_category
      # Create the change feed category subwindow and wait for a user action
      change_feed_category_window = ChangeFeedCategoryWindow.new(self, Wx::ID_ANY, 'Change feed category', self)
      change_feed_category_window.centre
      change_feed_category_window.show_modal
    end

    def add_category
      # Create the dialog box
      dialog = Wx::TextEntryDialog.new(self, 'Category name:', 'Add category')

      while dialog.show_modal == Wx::ID_OK
        category_name = dialog.get_value

        # Get the message from the validating function
        validation_message = Category.validate_add_category(category_name)

        if validation_message.empty?
          # Add the new category and regenerate the list of categories
          Category.add_category(category_name)
          @left_panel.generate_categories_list
          break
        else
          Wx::message_box(validation_message)

          # Show the dialog box again
          dialog = Wx::TextEntryDialog.new(self, 'Category name:', 'Add category')
        end
      end
    end

    def delete_category
      # Get the categories and the id of the main category
      categories = Category.current_user_categories
      general_category_id = Category.general_category_id

      # Remove the General category from the list
      categories.delete_if { |id, name| id == general_category_id }

      # Sort the categories by id, e.g the last is the one that was added last
      categories_ids = categories.keys.sort

      # Get the corresponding categories names
      categories_names = []
      categories_ids.each { |id| categories_names << categories[id] }

      # Create the dialog from which the user will choose which feed to delete
      category_deletion = Wx::SingleChoiceDialog.new(self, 'Select a category to be deleted:', 'Delete category', categories_names)

      # If the user clicked okay and not cancel do the deletion
      if category_deletion.show_modal == Wx::ID_OK
        category_name = category_deletion.get_string_selection
        unless category_name.empty?
          category_id = Category.id_from_name(category_name)

          # Delete the selected category and move its feeds to the main category
          Category.delete_category(category_id)

          # Regenerate the categories without the deleted one
          @left_panel.generate_categories_list
        end
      end
    end

    def delete_account
      # Goodbye, cruel world.
      User.delete_account

      # Close the window so that the user can login/register again
      close_window
    end

    def update_settings
      # Create the settings subwindow and wait for a user action
      settings_window = SettingsWindow.new(self, Wx::ID_ANY, 'Settings')
      settings_window.centre
      settings_window.show_modal
    end

    def display_about
      about_text = 'This dialog is supposed to help you, nah nah nah.'
      Wx::message_box(about_text, 'About', Wx::OK | Wx::ICON_INFORMATION)
    end

    def logout
      # Logout the current user
      User.logout

      # Close the window
      close_window
    end

    def close_window
      # Close the main window
      close(0)
    end
  end
end