require 'vcr'

VCR.configure do |config|
  config.hook_into :webmock
  config.cassette_library_dir = 'spec/vcr'
  config.ignore_localhost = true
end
