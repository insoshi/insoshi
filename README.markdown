# Insoshi social software

Insoshi is a social networking platform in Ruby on Rails. You can use Insoshi to make custom social networks; see the [Insoshi demo site](http://dogfood.insoshi.com/) for an example. For support, join the [Insoshi Google group](http://groups.google.com/group/insoshi/).

Insoshi was originally developed by [Michael Hartl](http://www.michaelhartl.com/) and Long Nguyen as part of the [Y Combinator](http://ycombinator.com/) program, and is presently maintained by Evan Dorn and [Logical Reality Design](http://lrdesign.com/).

## Installation prerequisites

The source code to Insoshi is managed via Git, a version control system developed by Linus Torvalds to host the Linux kernel.  


### Get Git

The first step is to [install Git](http://git.or.cz/). Linux and Mac users should have no problems; Windows users might have to install [Cygwin](http://cygwin.com/) first.

For more detailed information, check out our guide for Installing Git under the [Git Guides](http://docs.insoshi.com).

### Set up your local Git repository

  The Git Guides also detail our recommended setup for your local repository:

* Clone of the official repository
  ([git://github.com/insoshi/insoshi.git](git://github.com/insoshi/insoshi.git))
* Your GitHub fork added as a remote repository
* Local tracking branches for official 'master' and 'edge' branches
* Local development branch based off 'edge' and pushed to your GitHub fork

A [shell script](http://gist.github.com/18772) is available to automate this repository configuration. It is run from the command-line as follows:

    $ configure_insoshi_local.sh [GitHub Account Name]

### Install libraries and gems

There are several library and gem dependencies needed to run Insoshi.

#### Libraries

You'll need to install FreeImage or some other image processor (such as ImageMagick/RMagick) and a database (MySQL or PostgreSQL).  Install instructions for these are easy to find using Google.  (If you're installing FreeImage on Windows, [this blog post](http://www.thewebfellas.com/blog/2008/2/18/imagescience-on-windows-without-the-pain/comments/931#comment-931) might be helpful.)

To use Insoshi's search capability, you also need Sphinx.  Follow the instructions to [install Sphinx](http://www.sphinxsearch.com/downloads.html) for your platform.  When running Insoshi in a production envinronment, you should also set up a cron job to rotate the search index as described [here](http://blog.evanweaver.com/files/doc/fauna/ultrasphinx/files/DEPLOYMENT_NOTES.html). This currently works only with MySQL due to a bug in Ultrasphinx.

#### Gems

You probably have Rails already, but might not have the others.

    $ sudo gem install rails
    $ sudo gem install mysql     # for mysql support
    $ sudo gem install postgres  # for postgres support
    $ sudo gem install chronic

If you're using FreeImage/ImageScience, you'll also need the image_science gem:

    $ sudo gem install image_science
  
If you want Markdown formatting support you can install either RDiscount (fast but platform-dependent):

    $ sudo gem install rdiscount

or BlueCloth (slower but pure Ruby)

    $ sudo gem install BlueCloth


## Installing the app

These are the steps to get up and running with the Insoshi Rails app.

### Git steps

Our [public Git repository](http://github.com/insoshi/insoshi) is hosted on GitHub. You can clone the the repository with the command

    $ git clone git://github.com/insoshi/insoshi.git

The clone make take a moment to complete (mainly due to the frozen Rails gems).

Then make a local Git branch for yourself:

    $ git checkout -b <local_branch>

where you should replace <local_branch> with the name of your choice (without angle brackets!).  

For more information on configuring your local clone of our repository, check out our [Git Guides](http://docs.insoshi.com), which also includes a scripted Quick Local Repository Setup.

### Install script

To run the install script, you first need to set up your database configuration.  If you're using MySQL, you can just copy the example file as follows:

    $ cp config/database.example config/database.yml
  
Then open up database.yml and set up the passwords to match your system.

Run the following custom install script

    $ script/install

The install script runs the database migration and performs some additional setup tasks (generate an encryption keypair for password management, creating an admin account, etc.)

If the install step fails, you may not have properly set up your database configuration.

Then prepare the test database and run the tests (which are actually RSpec examples in the spec/ directory):

    $ rake db:test:prepare
    $ sudo gem install rspec-rails
    $ spec spec/

If the tests fail in the Photos controller test, double-check that an image processor is properly installed.

At this point, configure and start the Ultrasphinx daemon for the test runtime

    $ rake ultrasphinx:configure RAILS_ENV#test
    $ rake ultrasphinx:index RAILS_ENV#test
    $ rake ultrasphinx:daemon:start RAILS_ENV#test

and re-run the tests

    $ rake spec

The search specs detect whether the search daemon is running and weren't performed during the first test run.  An initial test run is needed in order to populate the test database for indexing (search specs would fail on an empty database).

To shut down the Ultrasphinx daemon for test

    $ rake ultrasphinx:daemon:stop RAILS_ENV#test

### Loading sample data

Now load the sample data

    $ rake db:sample_data:reload

configure and start the Ultrasphinx daemon for the development runtime

    $ rake ultrasphinx:configure
    $ rake ultrasphinx:index
    $ rake ultrasphinx:daemon:start

and start the server

    $ script/server

The rake task loads sample data to make developing easier.  All the sample users have email logins <name>@example.com, with password foobar.  

Go to [http://localhost:3000](http://localhost:3000) and log in as follows:

    email: michael@example.com
    password: foobar

### Admin user

To sign in as the pre-configured admin user, use

    email: admin@example.com
    password: admin

You should update the email address and password.  Insoshi will display warning messages to remind you to do that.

To see site preferences such as email settings, click on the "Admin view" and the click on "Prefs" in the menu.  Click the "Edit" link to customize the preferences for your particular site.

## License

Insoshi is released under the MIT License. See the LICENSE file for details.