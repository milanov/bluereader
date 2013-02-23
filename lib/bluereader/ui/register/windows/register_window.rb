module Bluereader
  class RegisterWindow < Wx::Dialog
    def initialize(parent, id, title)
      # Initialize the window from the parent constructor
      super

      id_register, id_exit = (1..2).to_a

      # Create the main sizer
      top_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
      set_sizer(top_sizer)

      # Create a sizer for the inputs and the labels and add it to the main sizer
      box_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
      top_sizer.add(box_sizer, 0, Wx::ALIGN_CENTER_HORIZONTAL | Wx::ALL, 5)

      # Create a label and an input for the username
      username_label = Wx::StaticText.new(self, Wx::ID_STATIC, 'Username:')
      box_sizer.add(username_label, 0, Wx::ALIGN_LEFT | Wx::ALL, 5)
      @username_input = Wx::TextCtrl.new(self, Wx::ID_ANY, '', Wx::DEFAULT_POSITION, [200, -1], 0)
      box_sizer.add(@username_input, 0, Wx::GROW | Wx::ALL, 5)

      # Create a label and an input for the password
      password_label = Wx::StaticText.new(self, Wx::ID_STATIC, 'Password:')
      box_sizer.add(password_label, 0, Wx::ALIGN_LEFT | Wx::ALL, 5)
      @password_input = Wx::TextCtrl.new(self, Wx::ID_ANY, '', Wx::DEFAULT_POSITION, [200, -1], Wx::TE_PASSWORD)
      box_sizer.add(@password_input, 0, Wx::GROW | Wx::ALL, 5)

      # Create a label and an input for the password confirmation
      password_confirmation_label = Wx::StaticText.new(self, Wx::ID_STATIC, 'Repeat password:')
      box_sizer.add(password_confirmation_label, 0, Wx::ALIGN_LEFT | Wx::ALL, 5)
      @password_confirmation_input = Wx::TextCtrl.new(self, Wx::ID_ANY, '', Wx::DEFAULT_POSITION, [200, -1], Wx::TE_PASSWORD)
      box_sizer.add(@password_confirmation_input, 0, Wx::GROW | Wx::ALL, 5)

      # Create a label and an input for the name
      full_name_label = Wx::StaticText.new(self, Wx::ID_STATIC, 'Full name:')
      box_sizer.add(full_name_label, 0, Wx::ALIGN_LEFT | Wx::ALL, 5)
      @full_name_input = Wx::TextCtrl.new(self, Wx::ID_ANY, '', Wx::DEFAULT_POSITION, [200, -1], 0)
      box_sizer.add(@full_name_input, 0, Wx::GROW | Wx::ALL, 5)

      # Draw a static horizonal line
      line = Wx::StaticLine.new(self, Wx::ID_STATIC)
      box_sizer.add(line, 0, Wx::GROW | Wx::ALL, 5)

      # Create a sizer for the register and exit buttons
      ok_cancel_box = Wx::BoxSizer.new(Wx::HORIZONTAL)
      box_sizer.add(ok_cancel_box, 0, Wx::ALIGN_RIGHT | Wx::ALL, 5)

      # Create and add an register/exit buttons to their sizer, placing them horizontally side by side
      register = Wx::Button.new(self, id_register, 'Register')
      ok_cancel_box.add(register, 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)
      exit = Wx::Button.new(self, id_exit, 'Exit')
      ok_cancel_box.add(exit, 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)

      # Sizes the window so that it fits around its subwindows
      top_sizer.fit(self)

      # Handle events for the exit and register buttons
      evt_button(id_register, :register)
      evt_button(id_exit, :close_window)

      self
    end

    def register
      # Get all form values
      username = @username_input.get_value
      password = @password_input.get_value
      password_confirmation = @password_confirmation_input.get_value
      full_name = @full_name_input.get_value

      if password == password_confirmation
        # The passwords match, so register and login the user, but only if the validations pass
        validation_message = User.validate_create_account(username, password, full_name)

        if validation_message.empty?
          # Register the user
          User.create_account(username, password, full_name)

          # Close the window
          close_window
        else
          Wx::message_box validation_message
        end
      else
        Wx::message_box("Passwords don't match.")
      end
    end

    def close_window
      # Close the dialog window with a return code 0 and destroy the window
      end_modal(0)
      destroy
    end
  end
end