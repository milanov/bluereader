module Bluereader
  class LoginWindow < Wx::Dialog
    def initialize(parent, id, title)
      # Initialize the window from the parent constructor
      super

      # Button ids
      id_login, id_register, id_exit = (1..3).to_a

      # Create the main sizer
      top_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
      set_sizer(top_sizer)

      # Create a sizer for the inputs and the labels and add it to the main sizer
      box_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
      top_sizer.add(box_sizer, Wx::ID_ANY, Wx::ALIGN_CENTER_HORIZONTAL | Wx::ALL, 5)

      # Create a sizer for the username and add it to the box sizer
      username_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
      box_sizer.add(username_sizer, 0, Wx::GROW | Wx::ALL, 5)

      # Create a label and an input for the username and add them to the inputs sizer
      username_label = Wx::StaticText.new(self, Wx::ID_STATIC, "Username:")
      username_sizer.add(username_label, 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)

      # Create the input for the username and display it
      @username_input = Wx::TextCtrl.new(self, Wx::ID_ANY, '', Wx::DEFAULT_POSITION, [200, -1], 0)
      username_sizer.add(@username_input, 0, Wx::GROW | Wx::ALL, 5)

      # Create a sizer for the password and add it to the box sizer
      password_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
      box_sizer.add(password_sizer, 0, Wx::GROW | Wx::ALL, 5)

      # Create a label and an input for the username and add them to the inputs sizer
      password_label = Wx::StaticText.new(self, Wx::ID_STATIC, "Password:")
      password_sizer.add(password_label, 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)

      # Create the input for the username and display it
      @password_input = Wx::TextCtrl.new(self, Wx::ID_ANY, '', Wx::DEFAULT_POSITION, [200, -1], Wx::TE_PASSWORD)
      password_sizer.add(@password_input, 0, Wx::GROW | Wx::ALL, 5)

      # Draw a static horizonal line
      line = Wx::StaticLine.new(self, Wx::ID_STATIC)
      box_sizer.add(line, 0, Wx::GROW | Wx::ALL, 5)

      # Create a sizer for the login, register and exit buttons
      ok_cancel_box = Wx::BoxSizer.new(Wx::HORIZONTAL)
      box_sizer.add(ok_cancel_box, 0, Wx::ALIGN_RIGHT | Wx::ALL, 5)

      # Create and add an login, register and exit buttons to their sizer, placing them horizontally side by side
      login = Wx::Button.new(self, id_login, 'Login')
      ok_cancel_box.add(login, 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)
      register = Wx::Button.new(self, id_register, 'Register')
      ok_cancel_box.add(register, 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)
      exit = Wx::Button.new(self, id_exit, 'Exit')
      ok_cancel_box.add(exit, 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)

      # Sizes the window so that it fits around its subwindows
      top_sizer.fit(self)

      # Handle events for the login, register and exit buttons
      evt_button(id_login, :login)
      evt_button(id_register, :register)
      evt_button(id_exit, :close_window)

      self
    end

    def login
      username, password = @username_input.get_value, @password_input.get_value

      if User.login(username, password)
        # Credentials are valid and the used is logged, so we close the login window
        close_window
      else
        Wx::message_box('Wrong username or password.')
      end
    end

    def register
      close_window

      register_window = Register.new
      register_window.main_loop
    end

    def close_window
      # Close the dialog window with a return code 0 and destroy the window
      end_modal(0)
      destroy
    end
  end
end