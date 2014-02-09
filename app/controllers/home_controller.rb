class HomeController < ApplicationController
  require 'json'
  require 'open-uri'

  def index
  end

  def sms_reply

    access_token = 'AIzaSyDt7rFMhlgsyWvtQUjLDI4Im5d72Jdq_4s'
    radius = 500;

    #if params['Body'].nil?
    #  action = 'knil'
    if params['Body'].split(",").size > 1
      action, city, state = params['Body'].split(",").map(&:strip)
      city = city.gsub(' ', '+') #unless defined? city
      state = state.gsub(' ', '+') #unless defined? city
    else
     action = 'h'
    end

    if action.downcase == 'hungry'
      query = 'restaurants+in+'+city+'+'+state
    elsif action.downcase == 'thirsty'
      query = 'bars+in+'+city+'+'+state
    else 
      @suggestion = 'You gotta do it like dis: "hungry, CITY, STATE" or "thirsty, CITY, STATE"'
    end
    
    fullURL = 'https://maps.googleapis.com/maps/api/place/textsearch/json?query=%s&radius=%d&key=%s&sensor=false' % [query, radius, access_token]

    contents = URI.parse(fullURL).read

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
    #client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])

    #client.account.sms.messages.create(
    #  from: TWILIO_CONFIG['from'],
    #  to: params['From'],
    #  body: @suggestion
    #)

    render 'sms_reply.xml.erb', :content_type => 'text/xml'
  end
end
