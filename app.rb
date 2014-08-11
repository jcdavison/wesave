require './config/setup'
require './models'

SECRET_VOLCANO_TOKEN = ENV["SECRET_VOLCANO_TOKEN"]

def budget
  Transaction.salary
end

def savings
  Transaction.all(description: "Savings").map(&:value).reduce(:+)
end

def discretionary_cash
  budget + Transaction.all_expenses
end

def projected_current_balance
  (budget + projected_current_expenses).round(2)
end

def projected_current_expenses
  Transaction.expenses_to_date + daily_discretionary_to_date
end

def actual_current_balance
  Balance.last.value
end

def current_budget_status
  (actual_current_balance - projected_current_balance).round(2)
end

def days_required_to_balance discount = nil
  discount ||= 0.5
  (current_budget_status / (daily_discretionary * discount)).round(2)
end

def daily_discretionary_to_date
  daily_discretionary * Time.now.day
end

def daily_discretionary
  (discretionary_cash/30).round(2)
end

get("/balance") do
  if params[:token]  && params[:token] == SECRET_VOLCANO_TOKEN
    Balance.last.to_json
  else
    "you are not authorized"
  end
end
