desc 'Start IRB with application environment loaded'
task :console do
  exec 'irb -r./config/setup -r./models.rb -r ./app.rb'
end

task :environment do
  require File.expand_path(File.join(*%w[ config setup ]), File.dirname(__FILE__))
  require File.expand_path(File.join(*%w[ app ]), File.dirname(__FILE__))
end

desc 'Create a Balance record.'
task :balance => :environment do
  Balance.generate
end

desc 'Send Love Note'
task :lovenote => :environment do
  Sms.send! FinancialLoveNote.create current_budget_status, daily_discretionary
end
