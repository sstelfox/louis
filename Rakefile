require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task :default => :spec
rescue LoadError
  # no rspec available
end

desc "Download the latest copy of the wireshark manufacturer's database"
task :update_wireshark => [:environment] do
  require 'net/http'

  begin
    new_file = Net::HTTP.get(URI('https://code.wireshark.org/review/gitweb?p=wireshark.git;a=blob_plain;f=manuf'))
    File.write(Louis::ORIGINAL_OUI_FILE, new_file)
    puts 'Update complete'
  rescue => err
    puts "An error occurred while downloading the file: #{err.class} -> #{err.message}"
  end
end

desc "Pre-parse the source file into the parsed file"
task :parse_data_file => [:environment] do
  include Louis::Helpers

  lookup_table = {}

  File.open(Louis::ORIGINAL_OUI_FILE).each_line do |line|
    next unless (res = line_parser(line))

    lookup_table[res['mask']] ||= {}
    lookup_table[res['mask']][res['prefix'].to_s] = {
      's' => res['short_vendor'],
      'l' => res['long_vendor']
    }.compact
  end

  File.write(Louis::PARSED_DATA_FILE, JSON.generate(lookup_table))
end

task :environment do
  base_path = File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
  $LOAD_PATH.unshift(base_path) unless $LOAD_PATH.include?(base_path)

  require 'louis'
end

desc "Start a pry session with the code loaded"
task :console => [:environment] do
  require 'pry'
  pry
end
