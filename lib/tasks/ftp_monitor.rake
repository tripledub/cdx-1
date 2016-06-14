namespace :ftp do
  desc "Start FTP monitor to download remote files"
  task start: :environment do
    FtpMonitor.new(300).run!
  end

  desc "Delete the failed file messages as a way to reprocess those files in the next monitoring iteration"
  task reset_failed: :environment do
    FileMessage.where(status: 'failed').delete_all
  end
end

namespace :ftp do
  desc "Start FTP monitor to download remote files"
  task :start, [:repeat] => :environment do |task, args|   
    run_time = 300
    if args[:repeat]
       run_time = args[:repeat].to_i
    end   
    
    FtpMonitor.new(run_time).run!
  end

  desc "Delete the failed file messages as a way to reprocess those files in the next monitoring iteration"
  task reset_failed: :environment do
    FileMessage.where(status: 'failed').delete_all
  end
end
