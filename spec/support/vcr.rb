require 'vcr'

VCR.configure do |config|
  config.hook_into :webmock
  config.cassette_library_dir = 'spec/vcr'
  config.ignore_localhost = true
  config.configure_rspec_metadata!
  # config.default_cassette_options = { record: :new_episodes }
end
