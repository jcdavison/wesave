require 'excon'
require 'pry'
require 'json'
require 'datamapper'


class FinReport
  def initialize budget = nil
    budget ||= 3500
    @monthly_budget = budget
  end
end

class Plaid
  attr_accessor :client_id, :secret, :access_token, :data

  def initialize
    @client_id =  ENV['PLAID_CLIENT_ID']
    @secret =  ENV['PLAID_SECRET']
    @access_token = ENV['PLAID_ACCESS_TOKEN']
    @data = nil
  end

  def request_data
    request = Excon.new('https://tartan.plaid.com')
    @data = JSON.parse( request.get(path: "/connect", query: {client_id: client_id, secret: secret, access_token: access_token}).body )
  end
end

class Sms
  attr_accessor :api

  def initialize
    @api = "https://api.twilio.com/2010-04-01"
  end
end
