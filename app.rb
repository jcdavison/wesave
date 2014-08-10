require './setup'
require './models'

SECRET_VOLCANO_TOKEN = ENV["SECRET_VOLCANO_TOKEN"]

get("/balance") do
  if params[:token] == SECRET_VOLCANO_TOKEN
    Balance.last.to_json
  else
    "you are not authorized"
  end
end
