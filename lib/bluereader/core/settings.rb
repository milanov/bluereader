module Bluereader
  class Setting < ActiveRecord::Base
    belongs_to :user

    class << self
      # Sets the number of days after the old news are being deleted for a specified user.
      def set_delete_after_days(user_id)
        create(:user_id => user_id, delete_after_days: 1)
      end

      # Validates the input for the #update_delete_after_days. Returns a proper message
      # if any error is present, and an empty string otherwise.
      def validate_update_delete_after_days(days)
        if String(days) !~ /^(0|[1-9]\d*)$/
          validation_message = 'Please enter a valid positive number.'
        end

        validation_message or ''
      end

      # Updates the number of days we store the news for the currently logged user.
      def update_delete_after_days(days)
        where(:user_id => User.current_user_id).update_all(:delete_after_days => days)
      end

      # Returns the number of days we store the news for the currently logged user.
      def get_delete_after_days
        where(:user_id => User.current_user_id).first.delete_after_days
      end

      # This method gave me a hard time when I tried to name it. It returns a time limit,
      # which is the current time in second - the days we keep the news in seconds.
      # Its use is in adding and deleting news, e.g. if a news has an older date than the
      # #keep_news_time, is deleted. Also, when adding, news older than this limit are not
      # added, because there's no point in adding and then deleting them.
      def keep_news_time
        Time.now.to_i -  get_delete_after_days*24*60*60
      end
    end
  end
end