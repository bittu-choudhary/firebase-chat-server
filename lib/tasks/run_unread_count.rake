task :unread_count => :environment do
  User.fetch_unread_count
end
