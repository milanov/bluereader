require 'wx'
require 'lib/bluereader/ui/main/windows/main_window'

module Bluereader
  class Main < Wx::App
    def on_init
      # Initialize and center the main window
      window = MainWindow.new(nil, Wx::ID_ANY, 'Bluereader', Wx::DEFAULT_POSITION, [900, 600])
      window.centre

      # Initialize and set the window icon
      icon_file = File.join(File.dirname(__FILE__), '..', 'resources/icon.png')
      icon = Wx::Icon.new(icon_file, Wx::BITMAP_TYPE_PNG, 16, 16);
      window.set_icon(icon);

      # Show the window
      window.show(true)
    end
  end
end