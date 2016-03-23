# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
env :PATH, ENV['PATH']
set :environment, "development"
set :output, {:error => "log/error.log", :standard => "log/cron.log"}
job_type :runner, %Q{export PATH=/opt/rbenv/shims:/opt/rbenv/bin:/usr/bin:$PATH; eval "$(rbenv init -)"; \
                         cd :path && rails runner "User.fetch_unread_count" --silent :output }

every 1.minute do
  runner "User.fetch_unread_count"
end
