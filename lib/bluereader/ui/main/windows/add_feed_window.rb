module Bluereader
  class AddFeedWindow < Wx::Dialog
    def initialize(parent, id, title, top_window)
      # Initialize the dialog window and center it
      super(parent, id, title)
      centre

      @top_window = top_window
      id_ok, id_cancel = (1..2).to_a

      # Create the main sizer
      top_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
      self.set_sizer(top_sizer)

      # Create a sizer for the inputs and the labels and add it to the main sizer
      box_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
      top_sizer.add(box_sizer, 0, Wx::ALIGN_CENTER_HORIZONTAL | Wx::ALL, 5)

      # Create a label and an input for the url and add them to the inputs sizer
      feed_url_label = Wx::StaticText.new(self, Wx::ID_STATIC, "Feed url:", Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, 0)
      box_sizer.add(feed_url_label, 0, Wx::ALIGN_LEFT | Wx::ALL, 5)
      @feed_input = Wx::TextCtrl.new(self, Wx::ID_ANY, '', Wx::DEFAULT_POSITION, [300, -1], 0)
      box_sizer.add(@feed_input, 0, Wx::GROW | Wx::ALL, 5)

      # Create a sizer for the categories and add it to the main sizer
      categories_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
      box_sizer.add(categories_sizer, 0, Wx::GROW | Wx::ALL, 5)

      # Create a label for the categories select cotrol and add it to the categories sizer
      category_label = Wx::StaticText.new(self, Wx::ID_STATIC, "Category:", Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, 0)
      categories_sizer.add(category_label, 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)

      # Get the categories in the form of id => name, id => name
      categories =  Category::current_user_categories

      # Sort the categories numerically on their ids
      categories_ids = categories.keys.sort

      # Get the names corresponding to the sorted ids
      categories_names = []
      categories_ids.each { |id| categories_names << categories[id] }

      # Create an select menu for the categories
      @category_input = Wx::Choice.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, [250, -1])

      # Add the categories and their ids as additional data
      0.upto(categories_names.size - 1) { |i| @category_input.append(String(categories_names[i]), categories_ids[i]) }


      # Select the first category from the select box and add it to the category sizer
      @category_input.set_selection(0)
      categories_sizer.add(@category_input, 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)

      #.add a spacer box
      categories_sizer.add(5, 5, 1, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)

      # Draw a static horizonal line
      line = Wx::StaticLine.new(self, Wx::ID_STATIC, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::LI_HORIZONTAL)
      box_sizer.add(line, 0, Wx::GROW | Wx::ALL, 5)

      # Create a sizer for the insert and cancel buttons
      ok_cancel_box = Wx::BoxSizer.new(Wx::HORIZONTAL)
      box_sizer.add(ok_cancel_box, 0, Wx::ALIGN_RIGHT | Wx::ALL, 5)

      # Create and add an insert/cancel buttons to their sizer, placing them horizontally side by side
      insert = Wx::Button.new(self, id_ok, 'Insert', Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, 0)
      ok_cancel_box.add(insert, 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)
      cancel = Wx::Button.new(self, id_cancel, 'Cancel', Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, 0)
      ok_cancel_box.add(cancel, 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)

      # Sizes the window so that it fits around its subwindows
      top_sizer.fit(self)

      # Handle events for the cancel and insert buttons
      evt_button(id_ok, :add_feed)
      evt_button(id_cancel, :close_dialog)

      self
    end

    def add_feed
      feed_url = @feed_input.get_value
      category_id = @category_input.get_client_data(@category_input.get_selection)

      # Get the message from the validation method
      validation_message = Feed.validate_add_feed(feed_url)

      if validation_message.empty?
        # Insert the feed url in the selected category
        Feed.add_feed(feed_url, category_id)

        # Regenerate the list of news in the right panel and the categories list in the left
        @top_window.left_panel.generate_categories_list
        @top_window.right_panel.generate_first_feeds_news

        # Close the dialog window
        close_dialog
      else
        # The validation didn't pass, show the returned message
        Wx::message_box(validation_message)
      end
    end

    def close_dialog
      # Close the dialog window with a return code 0
      end_modal(0)
    end
  end
end