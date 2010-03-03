module Cheepnis

  # starts up a Heroku worker if none are active
  # Author: Mike Traver Feb 2010

  # usage: set environment variables HEROKU_USER and HEROKU_PASSWORD
  # Call Cheepnis.enqueue(obj) in place of Delayed::Job.enqueue(obj)

  def self.enqueue(object)
    # enqueue the object in the normal way
    Delayed::Job.enqueue(object)
    if on_heroku
      # start a worker if necessary
      start
      # and enqueue something that calls maybe_stop, at low priortity
      terminator = Terminator.new
      Delayed::Job.enqueue(terminator, -10)    
    end
  end

  def self.on_heroku
    ENV["HEROKU_UPID"] != nil
  end

  def self.get_client
    Heroku::Client.new(ENV['HEROKU_USER'], ENV['HEROKU_PASSWORD'])
  end

  def self.start
    heroku = get_client
    info = heroku.info(ENV['APP_NAME'])
    workers = info[:workers].to_i
    if workers == 0
      heroku.set_workers(ENV['APP_NAME'], 1)
      Rails.logger.info('worker started')
    end
  end

  def self.stop
    heroku = get_client
    heroku.set_workers(ENV['APP_NAME'], 0)
    Rails.logger.info('worker stopped')
  end

  # this needs some experimentation
  def self.maybe_stop
    count = Delayed::Job.count
    if count == 1
      stop
    else
      # if there are actual jobs, fail so we will run again
      # won't work because jobs that fail many times get terminated
      # so just fall through and assume that a later terminator will run
      # throw "Not time to stop yet"
    end
  end

  class Terminator
    def perform
      Cheepnis.maybe_stop
    end
  end

end
