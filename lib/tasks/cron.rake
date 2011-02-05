desc "Cron -- gc workers"
task :cron => :environment do
  Cheepnis.maybe_stop
end
