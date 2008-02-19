Restful Authentication Generator
====

This is a basic restful authentication generator for rails, taken 
from acts as authenticated.  Currently it requires Rails 1.2.6 or above.

To use:

  ./script/generate authenticated user sessions \
		--include-activation \
		--stateful

The first parameter specifies the model that gets created in signup
(typically a user or account model).  A model with migration is 
created, as well as a basic controller with the create method.

The second parameter specifies the sessions controller name.  This is
the controller that handles the actual login/logout function on the 
site.

The third parameter (--include-activation) generates the code for a 
ActionMailer and its respective Activation Code through email.

The fourth (--stateful) builds in support for acts_as_state_machine
and generates activation code.  This was taken from:

http://www.vaporbase.com/postings/stateful_authentication

You can pass --skip-migration to skip the user migration.

If you're using acts_as_state_machine, define your users resource like this:

	map.resources :users, :member => { :suspend   => :put,
                                     :unsuspend => :put,
                                     :purge     => :delete }

Also, add an observer to config/environment.rb if you chose the 
--include-activation option

  config.active_record.observers = :user_observer # or whatever you 
																									# named your model

Security Alert
====

I introduced a change to the model controller that's been tripping 
folks up on Rails 2.0.  The change was added as a suggestion to help
combat session fixation attacks.  However, this resets the Form 
Authentication token used by Request Forgery Protection.  I've left
it out now, since Rails 1.2.6 and Rails 2.0 will both stop session
fixation attacks anyway.