# FindMassAssignment

## A Rails plugin to find likely mass assignment vulnerabilities

The <tt>find\_mass\_assignment</tt> Rake task defined by the plugin finds likely mass assignment problems in Rails projects.

The method is to scan the controllers for likely mass assignment, and then find the corresponding models that *don't* have <tt>attr\_accessible</tt> defined.  Any time that happens, it's a potential problem.

Install this plugin as follows:

    $ script/plugin install git://github.com/mhartl/find_mass_assignment.git


# Example

Suppose line 17 of the Users controller is

    @user = User.new(params[:user])

but the User model *doesn't* define <tt>attr_accessible</tt>.  Then we get the output

    $ rake find_mass_assignment

    /path/to/app/controllers/users_controller.rb
      17  @user = User.new(params[:user])

This indicates that the User model has a likely mass assignment vulnerability.

# Copyright

Copyright (c) 2008 Michael Hartl, released under the MIT license
