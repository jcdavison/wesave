require './config/setup'

class Balance
  include DataMapper::Resource
  attr_accessor :data, :budget

  property :id, Serial
  property :account_id, String, :required => true
  property :balance, Float, :required => true
  property :created_at,  DateTime, :required => true

  def initialize budget = nil
    budget ||= 3500
    @budget = budget
    @data = plaid
    @checking_account = select_checking
  end

  def plaid
    PlaidObject.get_data
  end

  def set_attributes
    self.account_id = @checking_account["_id"]
    self.balance = @checking_account["balance"]["current"]
    self.created_at = Time.now
  end

  def select_checking 
    data["accounts"].select {|account| account["meta"]["name"].match /CHECKING/ }.first
  end

  def self.generate
    balance = Balance.new
    balance.set_attributes
    balance.save
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

DataMapper.finalize
DataMapper.auto_upgrade!
