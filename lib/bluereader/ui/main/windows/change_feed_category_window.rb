module Bluereader
  class ChangeFeedCategoryWindow < Wx::Dialog
    def initialize(parent, id, title, top_window)
      # Initialize the dialog window and center it
      super(parent, id, title)
      centre

      id_ok = 1
      @top_window = top_window

      # Create the main sizer
      top_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
      set_sizer(top_sizer)

      # Create a sizer for the inputs and the labels and add it to the main sizer
      box_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
      top_sizer.add(box_sizer, 0, Wx::ALIGN_CENTER_HORIZONTAL | Wx::ALL, 5)

      # Create a sizer for the feeds and add it to the main sizer
      feeds_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
      box_sizer.add(feeds_sizer, 0, Wx::GROW | Wx::ALL, 5)

      # Create a label for the feed select cotrol and add it to the feeds sizer
      feed_label = Wx::StaticText.new(self, Wx::ID_STATIC, 'Feed:')
      feeds_sizer.add(feed_label, 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)
      feeds_sizer.add_spacer(20)

      # Get the feeds in the form of id => name, id => name
      feeds = Feed.feeds_list

      # Sort the feeds numerically on their ids
      feeds_ids = feeds.keys.sort

      # Get the names corresponding to the sorted ids
      feeds_names = []
      feeds_ids.each { |id| feeds_names << feeds[id] }

      # Create an select menu for the feeds
      @feed_input = Wx::Choice.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, [250, -1])

      # Add the feeds and their ids as additional data
      0.upto(feeds_names.size - 1) { |i| @feed_input.append(String(feeds_names[i]), feeds_ids[i]) }

      # Select the first feed from the select box and add it to the feeds sizer
      @feed_input.set_selection(0)
      feeds_sizer.add(@feed_input, 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)

      # Add a spacer box
      feeds_sizer.add(5, 5, 1, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)

      # Create a sizer for the categories and add it to the main sizer
      categories_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
      box_sizer.add(categories_sizer, 0, Wx::GROW | Wx::ALL, 5)

      # Create a label for the categories select cotrol and add it to the categories sizer
      category_label = Wx::StaticText.new(self, Wx::ID_STATIC, 'Category:')
      categories_sizer.add(category_label, 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)

      # Get the categories in the form of id => name, id => name
      categories =  Category.current_user_categories

      # Sort the categories numerically on their ids
      categories_ids = categories.keys.sort

      # Get the names corresponding to the sorted ids
      categories_names = []
      categories_ids.each { |id| categories_names << categories[id] }

      # Create an select menu for the categories
      @category_input = Wx::Choice.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, [250, -1])

      # Add the categories and their ids as additional data
      0.upto(categories_names.size - 1) { |i| @category_input.append(String(categories_names[i]), categories_ids[i]) }

      # Select the first feed from the select box and add it to the feeds sizer
      @category_input.set_selection(0)
      categories_sizer.add(@category_input, 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)

      # Add a spacer box
      categories_sizer.add(5, 5, 1, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)

      # Draw a static horizonal line
      line = Wx::StaticLine.new(self, Wx::ID_STATIC)
      box_sizer.add(line, 0, Wx::GROW | Wx::ALL, 5)

      # Create a sizer for the insert and cancel buttons
      ok_cancel_box = Wx::BoxSizer.new(Wx::HORIZONTAL)
      box_sizer.add(ok_cancel_box, 0, Wx::ALIGN_RIGHT | Wx::ALL, 5)

      # Create and add an insert/cancel buttons to their sizer, placing them horizontally side by side
      insert = Wx::Button.new(self, id_ok, 'Change')
      ok_cancel_box.add(insert, 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)
      cancel = Wx::Button.new(self, Wx::ID_CANCEL, 'Cancel')
      ok_cancel_box.add(cancel, 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)

      # Sizes the window so that it fits around its subwindows
      top_sizer.fit(self)

      # Handle events for the cancel and change feed buttons
      evt_button(id_ok, :change_feed_category)
      evt_button(Wx::ID_CANCEL, :close_dialog)

      self
    end

    def change_feed_category
      # Get the feed's url and the selected category's id
      feed_id = @feed_input.get_client_data(@feed_input.get_selection)
      category_id = @category_input.get_client_data(@category_input.get_selection)

      # Insert the feed url in the selected category
      Feed.change_feed_category(feed_id, category_id)

      # Regenerate the list of news in the right panel and the categories list in the left
      @top_window.left_panel.generate_categories_list
      @top_window.right_panel.generate_first_feeds_news

      # Close the dialog window with a return code of 0
      close_dialog
    end

    def close_dialog
      # Close the dialog window with a return code 0
      end_modal(0)
    end
  end
end