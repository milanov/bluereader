require 'wx'
require 'lib/bluereader/ui/login/windows/login_window'

module Bluereader
  class Login < Wx::App
    def on_init
      # Initialize and center the main window
      window = LoginWindow.new(nil, Wx::ID_ANY, 'Login to Bluereader')
      window.centre

      # Initialize and set the window icon
      icon_file = File.join(File.dirname(__FILE__), '..', 'resources/icon.png')
      icon = Wx::Icon.new(icon_file, Wx::BITMAP_TYPE_PNG, 16, 16)
      window.set_icon(icon)

      # Show the window and wait for a user action
      window.show
      window.show_modal
    end
  end
end