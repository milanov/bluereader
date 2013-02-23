require 'active_record'
require 'arss'

# Connect to the database, but ENV['environment'] has to be set before this file is required,
# so that the database could know in which envoronment is working.
require 'db/dbconnect'

# The order in which the files are included, sadly, matters.
require 'lib/bluereader/core/users'
require 'lib/bluereader/core/categories'
require 'lib/bluereader/core/feeds'
require 'lib/bluereader/core/news'
require 'lib/bluereader/core/settings'