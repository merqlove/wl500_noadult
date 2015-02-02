load 'lib/filter_parser.rb'
load 'lib/filter_uploader.rb'

Dir.glob('tasks/*.rake').each { |r| import r }

task :default => 'filter:update'
