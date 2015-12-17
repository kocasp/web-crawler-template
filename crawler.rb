require 'capybara/poltergeist'
require 'capybara/dsl'

class PoltergeistCrawler
  include Capybara::DSL

  def initialize
    Capybara.register_driver :poltergeist_crawler do |app|
      Capybara::Poltergeist::Driver.new(app, {
        :js_errors => false,
        :inspector => false,
        phantomjs_logger: open('/dev/null') # if you don't care about JS errors/console.logs
      })
    end
    Capybara.default_wait_time = 3
    Capybara.run_server = false
    Capybara.default_driver = :poltergeist_crawler
    page.driver.headers = {
      "DNT" => 1,
      "User-Agent" => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:22.0) Gecko/20100101 Firefox/22.0"
    }
  end

  # handy to peek into what the browser is doing right now
  def screenshot(name="screenshot")
    page.driver.render("public/#{name}.jpg",full: true)
  end

  # find("path") and all("path") work ok for most cases. Sometimes I need more control, like finding hidden fields
  def doc
    Nokogiri.parse(page.body)
  end

  def crawl
    visit "https://news.ycombinator.com/"
    click_on "More"
    page.evaluate_script("window.location = '/'")
  end

end

p = PoltergeistCrawler.new
p.crawl
p.screenshot
