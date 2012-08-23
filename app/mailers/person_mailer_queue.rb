# Where one could write 
#   PersonMailer.some_method(*args).deliver
# the same action is performed by GirlFriday using
#   PersonMailerQueue.some_method(*args)
# 
class PersonMailerQueue < GirlFriday::WorkQueue
  include Singleton

  def initialize
    super(:person_mailer, :size => 1) do |msg|
      PersonMailer.send(msg[:method], *msg[:args]).deliver
    end
  end

  def self.push *args
    instance.push *args
  end

  # If a method is called, which corresponds to a method of the mailer, 
  # then the corresponding task is enqueued. Otherwise, fallback to the
  # superclass's behavior.
  def self.method_missing(method, *args)
    return super(method, *args) unless PersonMailer.respond_to?(method)
    args = args.collect do |arg|
      arg.is_a?(ActiveRecord::Base) ? arg.id : arg
    end
    push :method => method, :args => args
  end

end
