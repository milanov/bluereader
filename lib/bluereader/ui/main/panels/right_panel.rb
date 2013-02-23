module Bluereader
  class RightPanel < Wx::ScrolledWindow
    def initialize(parent, top_window)
      super(parent, Wx::ID_ANY)

      @top_window = top_window

      # Generate the news for the first feed (the one that is marked in the left panel)
      generate_first_feeds_news

      self
    end

    def generate_first_feeds_news
      news_for_feed = News.news_for_feed(Feed.first_feed_id)

      # Generate the news list using the news belonging to the first feed
      generate_news_list(news_for_feed)
    end

    def generate_news_list(news)
      @current_news = news

      # Remove the current news
      freeze
      destroy_children

      vbox = Wx::BoxSizer.new(Wx::VERTICAL)
      news.each do |news_item|
        # Create a panel for the current news item
        news_panel = Wx::Panel.new(self, Wx::ID_ANY)

        # Create the current news item sizer and its title control
        news_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
        news_title = Wx::HyperlinkCtrl.new(news_panel, news_item['id'], news_item['title'], news_item['url'],  Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::BORDER_NONE)

        # Make the font normal
        font = Wx::Font.new(10, Wx::DEFAULT, Wx::NORMAL, Wx::NORMAL)
        news_title.set_font(font)

        # If the news is not read, make it bold
        unless news_item['read']
          bold_font = Wx::Font.new(10, Wx::DEFAULT, Wx::NORMAL, Wx::BOLD)
          news_title.set_font(bold_font)
        end

        # Create the description and the date controls of the news item
        news_description = Wx::StaticText.new(news_panel, Wx::ID_ANY, news_item['description'], Wx::DEFAULT_POSITION)
        news_description.wrap(560)
        date = Time.at(news_item['date']).to_datetime.strftime("%H:%I, %d %B, %Y")
        news_date = Wx::StaticText.new(news_panel, Wx::ID_ANY, date)
        date_font = Wx::Font.new(7, Wx::DEFAULT, Wx::NORMAL, Wx::BOLD)
        news_date.set_font(date_font)

        # Draw a static horizonal line to separate the news from each other
        news_separator = Wx::StaticLine.new(news_panel, Wx::ID_ANY)

        # Add all these controls to the news sizer, separated by some space
        news_sizer.add_spacer(5)
        news_sizer.add(news_title, 0)
        news_sizer.add_spacer(5)
        news_sizer.add(news_description, 0)
        news_sizer.add_spacer(5)
        news_sizer.add(news_date, 0)
        news_sizer.add_spacer(5)
        news_sizer.add(news_separator, 0, Wx::EXPAND | Wx::ALIGN_LEFT , 20)

        # Add the sizer to the news panel
        news_panel.set_sizer(news_sizer)

        # Add the whole panel to the main sizer
        vbox.add(news_panel, 0, Wx::EXPAND | Wx::ALL)

        # Handle clicks on news
        evt_hyperlink(news_item['id'], :news_clicked)
      end

      # Set the window sizer and add it a scroll
      set_sizer(vbox)
      set_scroll_rate(10, 10)
      vbox.fit(self)
      thaw

      # MY WORK HERE IS DONE
      window_size = @top_window.get_size
      width = window_size.width
      height = window_size.height

      @top_window.set_size(width, height + 1)
      @top_window.set_size(width, height)
    end

    def news_clicked(news_item)
      # Mark the current news as read
      news_url = news_item.get_url
      News.read_news_item(news_url)

      # Mark the clicked news as read
      @current_news.each do |single_news|
        if single_news['url'] = news_url
          single_news['read'] = true
          break
        end
      end

      # Regenerate the categories list
      @top_window.left_panel.generate_categories_list

      # Regenerate the news list with the current news
      generate_news_list(@current_news)

      # Open the news url in the default browser
      Wx::launch_default_browser(news_url)
    end
  end
end