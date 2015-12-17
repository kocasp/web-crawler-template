require 'capybara/poltergeist'
require 'capybara/dsl'
require 'selenium-webdriver'

class PoltergeistCrawler
  include Capybara::DSL

  def initialize
    Capybara.register_driver :poltergeist_crawler do |app|
      Capybara::Poltergeist::Driver.new(app, :phantomjs => "H:/phantomjs.exe", :phantomjs_options => ['--proxy=142.4.200.240:3129'])
    end
    Capybara.register_driver :selenium do |app|   
      profile = Selenium::WebDriver::Firefox::Profile.new

      profile["network.proxy.type"] = 1  
      profile["network.proxy.http"] = '142.4.200.240'                                                                                                                              
      profile["network.proxy.http_port"] = 3129 

      Capybara::Selenium::Driver.new(app, browser: :firefox, profile: profile)
    end

    Capybara.default_max_wait_time = 3
    Capybara.run_server = false
    Capybara.default_driver = :poltergeist_crawler  
    # page.driver.headers = {
    #   "DNT" => 1,
    #   "User-Agent" => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:22.0) Gecko/20100101 Firefox/22.0"
    # }
  end

  # handy to peek into what the browser is doing right now
  def screenshot(name="screenshot")
    page.driver.render("#{name}.jpg",full: true)
  end

  # find("path") and all("path") work ok for most cases. Sometimes I need more control, like finding hidden fields
  def doc
    Nokogiri.parse(page.body)
  end

  def crawl
    filename = Time.now.to_s.split(" ")[0]+"_"+Time.now.to_s.split(" ")[1].gsub(":","-")
    file = File.new("#{filename}.txt", "w")

    visit "http://www.futbol24.com/team/Qatar/Al-Wakra/results/"

    no_pages = (find('#number-total').text.to_i/50).floor

    no_pages.times do 
      all(".dash .black.matchAction").each do |result|
        result.trigger('click')
        sleep 1
        screenshot
        info = find('.actioninfo.loadingContainer').text
        home = find(".home a").text
        guest = find(".guest a").text

        if all('.action.action.action .result')[0]
          ht_result = all(".action.action.action .result")[0].text
          ft_result = all(".action.action.action .result")[1].text
        end

        if check_result(ht_result, ft_result)
          p "!!!!!!!!!!!!!!!!!!!!!!! FOUND !!!!!!!!!!!!!!!!!!!!!!!!!"
          file_print_results(ht_result, ft_result, info, home, guest, file)
        end

        console_print_results(ht_result, ft_result, info, home, guest)

      end

      find(".buttongreen.next a").trigger('click')
      sleep 2
    end

    file.close

    # click_on "More"
    # page.evaluate_script("window.location = '/'")
  end

  def check_result(ht_result, ft_result)
    ht1 = ht_result.split(//).first.to_i
    ht2 = ht_result.split(//).last.to_i

    ft1 = ft_result.split(//).first.to_i
    ft2 = ft_result.split(//).last.to_i
    if (ht1 < ht2) && (ft1 > ft2)
      true
    elsif (ht1 > ht2) && (ft1 < ft2)
      true
    else
      false
    end
  end

  def console_print_results(ht_result, ft_result, info, home, guest)
    puts "---------------------"
    puts info
    puts "#{home} vs #{guest}"
    puts "HT: #{ht_result}"
    puts "FT: #{ft_result}"
  end

  def file_print_results(ht_result, ft_result, info, home, guest, file)
    file.puts "---------------------"
    file.puts info
    file.puts "#{home} vs #{guest}"
    file.puts "HT: #{ht_result}"
    file.puts "FT: #{ft_result}"
  end

end

p = PoltergeistCrawler.new
p.crawl
