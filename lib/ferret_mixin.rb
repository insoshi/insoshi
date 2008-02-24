# This gets Ferret to play nice with will_paginate
module ActsAsFerret
  module ClassMethods
    alias find_all_by_contents find_by_contents
  end
end
