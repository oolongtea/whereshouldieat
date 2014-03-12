class HomeController < ApplicationController
  require 'json'
  require 'open-uri'

  def index
  end

  def sms_reply

    access_token = TWILIO_CONFIG[:google_token]
    radius = 500;

    # follow this if user entered ACTION, ZIPCODE
    if params['Body'].split(",").size == 2 
      action, zipcode = params['Body'].split(",").map(&:strip)

      # compile appropriate query depending on action
      query = 'restaurants+in+' + zipcode if action.downcase == 'hungry'
      query = 'bars+in+' + zipcode if action.downcase == 'thirsty'
        @suggestion = 'You gotta do it like dis: "hungry, CITY, STATE" or "thirsty, CITY, STATE"' if action.downcase != 'thirsty' && action.downcase != 'hungry'
    
    # follow this if user entered ACTION, CITY, STATE    
    else
      # parse user request if correct usage
      if params['Body'].split(",").size == 3
        action, city, state = params['Body'].split(",").map(&:strip)
        city = city.gsub(' ', '+') #if city.nil?
        state = state.gsub(' ', '+') #if city.nil?
      else
       action = 'h'
      end

      # compile appropriate query depending on action
      if action.downcase == 'hungry'
        query = 'restaurants+in+'+city.to_s+'+'+state.to_s
      elsif action.downcase == 'thirsty'
        query = 'bars+in+'+city.to_s+'+'+state.to_s
      else 
        @suggestion = 'You gotta do it like dis: "hungry, CITY, STATE" or "thirsty, CITY, STATE"'
      end
    end
    
    # create the Google Maps URL
    fullURL = 'https://maps.googleapis.com/maps/api/place/textsearch/json?query=%s&radius=%d&key=%s&sensor=false' % [query, radius, access_token]

    # fetch results from Google Maps
    contents = URI.parse(fullURL).read

    # parse JSON data from Google API
    c = JSON.parse(contents)

      if c['status'] == 'OK'
        names = []
        address = []
        c['results'].each do |n|
          names << n['name']
          address << n['formatted_address']
        end
      end

      unless defined? @suggestion
        i = rand(names.size) - 1
        @suggestion = names[i] + ' | ' + address[i]  
      end

    render 'sms_reply.xml.erb', :content_type => 'text/xml'
  end
end
