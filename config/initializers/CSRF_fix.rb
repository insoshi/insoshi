# Fix for CSRF protection bug.
# See http://weblog.rubyonrails.org/2008/11/18/potential-circumvention-of-csrf-protection-in-rails-2-1
Mime::Type.unverifiable_types.delete(:text)