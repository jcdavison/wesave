require './setup'

class Report
  attr_accessor :data, :budget

  def initialize budget = nil
    budget ||= 3500
    @budget = budget
    @data = plaid
  end

  def plaid
    PlaidObject.get_data
  end
end

class PlaidObject
  attr_accessor :client_id, :secret, :access_token, :data

  def self.get_data
    plaid = PlaidObject.new
    plaid.request_data
    plaid.data
  end

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
