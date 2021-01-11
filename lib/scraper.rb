require 'open-uri'
require 'nokogiri'
require 'pry'

class Scraper

  def self.scrape_index_page(index_url)
    index_page = Nokogiri::HTML(open("#{index_url}"))
    scraped_students = []

    index_page.css("div.roster-cards-container").each do |card|
      card.css(".student-card a").each do |student|
        s_name = student.css(".student-name").text
        s_location = student.css(".student-location").text
        s_profile_url = "#{student.attr("href")}"
        scraped_students << {
          name: s_name,
          location: s_location,
          profile_url: s_profile_url
        }
      end
    end
    scraped_students
  end

  def self.scrape_profile_page(profile_url)
    profile_page = Nokogiri::HTML(open("#{profile_url}"))
    student = {}

    socials = profile_page.css(".social-icon-container").children.css("a").collect do |link|
      link.attribute("href").value
    end

    socials.each do |s|
      if s.include?("twitter")
        student[:twitter] = s
      elsif s.include?("linkedin")
        student[:linkedin] = s
      elsif s.include?("github")
        student[:github] = s
      else 
        student[:blog] = s
      end
    end

    if profile_page.css(".profile-quote")
      student[:profile_quote] = profile_page.css(".profile-quote").text 
    end

    if profile_page.css(".description-holder p")
      student[:bio] = profile_page.css(".description-holder p").text
    end

    student
  end

end

