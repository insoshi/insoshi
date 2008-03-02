# You'll need to <tt>require 'markaby/kernel_method'</tt> for this.
module Kernel
  # Shortcut for creating a quick block of Markaby.
  def mab(*args, &block)
    Markaby::Builder.new(*args, &block).to_s
  end
end