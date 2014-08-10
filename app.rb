require './config/setup'
require './models'

SECRET_VOLCANO_TOKEN = ENV["SECRET_VOLCANO_TOKEN"]

def projected_current_balance
  projected_current_expenses = Transaction.expenses_to_date.map(&:value).reduce(:+) + allowance_to_date
  BUDGET + projected_current_expenses
end

def actual_current_balance
  Balance.last.value
end

def current_budget_status
  projected_current_balance - actual_current_balance
end

def days_required_to_balance discount = nil
  discount ||= 0.5
  (current_budget_status / (daily_allowance * discount)).round(2)
end

def allowance_to_date
  daily_allowance * Time.now.day
end

def daily_allowance
  (Transaction.first(description: "Allowance").value)/30
end

get("/balance") do
  if params[:token]  && params[:token] == SECRET_VOLCANO_TOKEN
    Balance.last.to_json
  else
    "you are not authorized"
  end
end
