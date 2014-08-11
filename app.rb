require './config/setup'
require './models'

SECRET_VOLCANO_TOKEN = ENV["SECRET_VOLCANO_TOKEN"]

def budget
  Transaction.all_credits.map(&:value).reduce(:+) + Transaction.all_expenses.map(&:value).reduce(:+)
end

def projected_current_balance
  projected_current_expenses = Transaction.expenses_to_date.map(&:value).reduce(:+) + allowance_to_date
  (budget + projected_current_expenses).round(2)
end

def actual_current_balance
  Balance.last.value
end

def current_budget_status
  (actual_current_balance - projected_current_balance).round(2)
end

def days_required_to_balance discount = nil
  discount ||= 0.5
  (current_budget_status / (daily_allowance * discount)).round(2)
end

def allowance_to_date
  daily_allowance * Time.now.day
end

def total_expenses
  Transaction.all_expenses.map(&:value).reduce(:+)
end

def daily_allowance
  ((budget + total_expenses)/30).round(2)
end

get("/balance") do
  if params[:token]  && params[:token] == SECRET_VOLCANO_TOKEN
    Balance.last.to_json
  else
    "you are not authorized"
  end
end
