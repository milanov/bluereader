$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

ENV['environment'] = 'development'
require 'lib/bluereader'

require 'lib/bluereader/ui/register/register'

register_window = Bluereader::Register.new
register_window.main_loop