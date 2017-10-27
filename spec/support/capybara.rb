require 'capybara/rspec'
require 'capybara-screenshot/rspec'

if ENV['SELENIUM_SERVER']
  remote = ENV['SELENIUM_SERVER']
  port = ENV['SELENIUM_PORT'] || 4444
  browser = (ENV['SELENIUM_BROWSER'] || 'chrome').to_sym
  Capybara.register_driver :selenium_remote do |app|
    url = "http://#{remote}:#{port}/wd/hub"
    Capybara::Selenium::Driver.new(app, browser: :remote, url: url, desired_capabilities: browser)
  end

  Capybara.javascript_driver = :selenium_remote
end
