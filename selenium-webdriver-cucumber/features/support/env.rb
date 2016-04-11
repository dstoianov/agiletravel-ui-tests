require 'rubygems'
require 'selenium-webdriver'
gem "minitest"
require "minitest/autorun"
# require 'test/unit/assertions'

require File.join(File.dirname(__FILE__), "..","..", "pages", "abstract_page.rb")
Dir["#{File.dirname(__FILE__)}/../../pages/*_page.rb"].each { |file| load file }

if defined?(TestWiseRuntimeSupport)
  ::TestWise::Runtime.load_webdriver_support # for selenium webdriver support
end

$BASE_URL = "http://travel.agileway.net"
def the_browser
  if $TESTWISE_BROWSER then
    $TESTWISE_BROWSER.downcase.to_sym
  elsif ENV["BROWSER"] &&  ENV["BROWSER"].size > 1
    ENV["BROWSER"].downcase.to_sym
  else
    RUBY_PLATFORM =~ /mingw/ ? "ie".to_sym : "firefox".to_sym
  end
end
browser = Selenium::WebDriver.for(the_browser)

# World(Test::Unit::Assertions)
World(Minitest::Assertions)

Before do
  @browser = @driver = browser
  goto_home_page
end

After do |scenario|
  if scenario.failed?
    puts "Scenario failed: #{scenario.inspect} | #{scenario.exception.message}"
  end
end

at_exit do
  browser.close if browser
end

## Helper methods
#
def goto_home_page
  $base_url = base_url = $TESTWISE_PROJECT_BASE_URL || $BASE_URL
  @browser.navigate.to("#{base_url}")
end

# if your applicant supports reset datbase
def reset_database
  $base_url = base_url = $TESTWISE_PROJECT_BASE_URL || $BASE_URL
  @browser.navigate.to("#{base_url}/reset")
  goto_home_page
end

def sign_in(user, pass)
  @browser.find_element(:id, "username").send_keys(user)
  @browser.find_element(:id, "password").send_keys(pass)
  @browser.find_element(:xpath,"//input[@value=\"Sign in\"]").click
end
