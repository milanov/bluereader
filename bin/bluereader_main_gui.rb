$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

ENV['environment'] = 'development'
require 'lib/bluereader'

require 'lib/bluereader/ui/login/login'
require 'lib/bluereader/ui/register/register'
require 'lib/bluereader/ui/main/main'

def login_window
  login_window = Bluereader::Login.new
  login_window.main_loop
end

# Show the login window if no user is currently logged in
if Bluereader::User.current_user_id.zero?
  login_window
end

while Bluereader::User.current_user_id.nonzero? do

  # News::delete_old_news_if_necessary();
  # my @feeds_ids = keys %{Feeds::get_feeds_names()};
  # News::insert_news_if_necessary($_) foreach(@feeds_ids);

  application = Bluereader::Main.new
  application.main_loop

  if Bluereader::User.current_user_id.zero?
    login_window
  else
    break
  end
end