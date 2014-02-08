class HomeController < ApplicationController

  def index
  end

  def sms_reply

    render params

    @suggestion = "Cook food you lazy!"
    
    client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])

    client.account.sms.messages.create(
      from: TWILIO_CONFIG['from'],
      to: params['From'],
      body: @suggestion
    )


    #render 'sms_reply.xml.erb', :content_type => 'text/xml'
  end
end
