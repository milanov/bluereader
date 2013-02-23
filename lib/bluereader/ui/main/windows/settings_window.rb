module Bluereader
  class SettingsWindow < Wx::Dialog
    def initialize(parent, id, title)
      # Initialize the dialog window and center it
      super
      centre

      id_ok = 1

      # Create the main sizer
      top_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
      set_sizer(top_sizer)

      # Create a sizer for the inputs and the labels and add it to the main sizer
      box_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
      top_sizer.add(box_sizer, 0, Wx::ALIGN_CENTER_HORIZONTAL | Wx::ALL, 5)

      # Create a sizer for the 'delete after' days and add it to the main sizer
      delete_after_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
      box_sizer.add(delete_after_sizer, 0, Wx::GROW | Wx::ALL, 5)

      # Create a label and an input for the 'delete after days' and add them to the inputs sizer
      delete_after_label = Wx::StaticText.new(self, Wx::ID_STATIC, 'Delete news after (in days):')
      delete_after_sizer.add(delete_after_label, 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)

      # The current 'delete after' days
      current_delete_after_days = Setting.get_delete_after_days

      # Create the input for the delete after days and display it
      @delete_after_days_input = Wx::TextCtrl.new(self, Wx::ID_ANY, String(current_delete_after_days), Wx::DEFAULT_POSITION, [200, -1], 0)
      delete_after_sizer.add(@delete_after_days_input, 0, Wx::GROW | Wx::ALL, 5)

      # Draw a static horizonal line
      line = Wx::StaticLine.new(self, Wx::ID_STATIC)
      box_sizer.add(line, 0, Wx::GROW | Wx::ALL, 5)

      # Create a sizer for the update and cancel buttons
      ok_cancel_box = Wx::BoxSizer.new(Wx::HORIZONTAL)
      box_sizer.add(ok_cancel_box, 0, Wx::ALIGN_RIGHT | Wx::ALL, 5)

      # Create and add an update/cancel buttons to their sizer, placing them horizontally side by side
      update = Wx::Button.new(self, id_ok, 'Update')
      ok_cancel_box.add(update, 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)
      cancel = Wx::Button.new(self, Wx::ID_EXIT, 'Cancel')
      ok_cancel_box.add(cancel, 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALL, 5)

      # Sizes the window so that it fits around its subwindows
      top_sizer.fit(self)

      # Handle events for the cancel and update buttons
      evt_button(id_ok, :update_settings)
      evt_button(Wx::ID_EXIT, :close_dialog)

      self
    end

    def update_settings
      # Get the number of days in which we keep the news before deleting them
      delete_after_days = @delete_after_days_input.get_value

      validation_message = Setting.validate_update_delete_after_days(delete_after_days)
      if validation_message.empty?
        # Update the  number of days we keep the news
        Setting.update_delete_after_days(delete_after_days)

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