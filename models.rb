require './config/setup'

class Transaction
  include DataMapper::Resource

  property :id, Serial
  property :day, Integer, :required => true
  property :value, Float, :required => true
  property :description, String, :required => true

  def self.expenses_to_date
    Transaction.all(:day.lte => Time.now.day, :value.lt => 0).map(&:value).reduce(:+)
  end

  def self.salary
    Transaction.first(:description => "Salary").value
  end

  def self.all_expenses
    Transaction.all(:value.lt => 0).map(&:value).reduce(:+)
  end

  def self.all_credits
    Transaction.all(:value.gt => 0)
  end

  def self.expenses_pending
    Transaction.all(:day.gt => Time.now.day, :value.lt => 0)
  end

  def self.credits_to_date
    Transaction.all(:day.lte => Time.now.day, :value.gt => 0)
  end
end

class Balance
  include DataMapper::Resource
  attr_accessor :data

  property :id, Serial
  property :account_id, String, :required => true
  property :value, Float, :required => true
  property :created_at,  DateTime, :required => true

  def initialize
    @data = plaid
    @checking_account = select_checking
  end

  def plaid
    PlaidObject.get_data
  end

  def set_attributes
    self.account_id = @checking_account["_id"]
    self.value = @checking_account["balance"]["current"]
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
  attr_accessor :client, :from, :to

  def initialize
    @sid = ENV['TWILIO_ACCOUNT_SID']
    @token = ENV['TWILIO_AUTH_TOKEN']
    @client = Twilio::REST::Client.new @sid, @token
    @from = ENV['TWILIO_FROM_NUMBER']
    @to = ENV['JD_CELLPHONE']
  end

  def self.send! message
    sms = Sms.new
    payload = {from: sms.from, to: sms.to, body: message}
    sms.client.account.messages.create payload
  end
end

class FinancialLoveNote
  def self.create balance
      "Congratulations, Your current balance is #{balance}, good luck with that."
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!
