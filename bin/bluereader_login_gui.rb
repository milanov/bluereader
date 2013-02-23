$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

ENV['environment'] = 'development'
require 'lib/bluereader'

require 'lib/bluereader/ui/login/login'

register_window = Bluereader::Login.new
register_window.main_loop