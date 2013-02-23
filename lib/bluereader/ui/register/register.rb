require 'wx'
require 'lib/bluereader/ui/register/windows/register_window'

module Bluereader
  class Register < Wx::App
    def on_init
      # Initialize and center the register window
      window = RegisterWindow.new(nil, Wx::ID_ANY, 'Register to Bluereader')
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