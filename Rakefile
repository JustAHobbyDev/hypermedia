require 'rake'
require 'rspec/core/rake_task'

# Ensure development environment dependencies are loaded
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __FILE__)

# Add models directory to load path
$LOAD_PATH.unshift File.expand_path('models', __dir__)

# Define the RSpec task
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb' # Run all files ending in _spec.rb in spec directory
  t.verbose = true # Show detailed output
  t.rspec_opts = ['--format documentation', '--color'] # Use documentation format with color
end

# Set the default task to run specs
task default: :spec

# Optional: Add a rescue block to handle missing RSpec in production
begin
  require 'rspec'
rescue LoadError
  desc 'Warn if RSpec is not available'
  task :spec do
    abort 'RSpec is not installed. Please run `bundle install --with development` to install development dependencies.'
  end
end
