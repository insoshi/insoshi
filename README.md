[![Build Status](https://travis-ci.org/oscurrencyVRL/oscurrency.png?branch=master)](https://travis-ci.org/oscurrencyVRL/oscurrency)

### Quick Facts
- ruby 1.9.3
- rails 3.2.16
- heroku deployment
- [Issues](https://github.com/oscurrency/oscurrency/issues)
- [Demo site](http://demo.opensourcecurrency.org)
- [Contributors](https://github.com/oscurrency/oscurrency/graphs/contributors)

### Features
- [OpenTransact](http://opentransact.org) compatibility
- Mutual Credit Accounting
- Internal Messaging System
- Multiple currency support
- Internationalization includes Spanish, Greek, French
- Advanced Search Filters
- Email Notification for matched requests
- [Android native app w/OpenTransact](https://play.google.com/store/apps/details?id=org.opensourcecurrency.hack)
- OpenID compatibility
- [Easy Heroku installation and update](https://github.com/oscurrency/oscurrency/wiki/Heroku-Deployment-Guide)

### Install

Our public Git repository is hosted on GitHub and can be viewed at

  https://github.com/oscurrency/oscurrency

You can install a new deployment on Heroku with the command:

    $ rake heroku:install

Update a Heroku deployment with:

    $ rake heroku:update

**Tutorial for Heroku install**: [A Guide for Non-Developers who want to deploy OSCurrency](https://github.com/oscurrency/oscurrency/wiki/Heroku-Deployment-Guide)

### Admin user

To sign in as the pre-configured admin user, use

- email: admin@example.com
- password: admin

You should update the email address and password.

### Administration and Configuration

After install, log in with the default admin@example.com account (password is admin) and click on the "Admin View" link in the upper right. This will take you to the Site administration page ([rails_admin](https://github.com/sferik/rails_admin)). Click on "Preferences" in the left panel and your app name will be listed.  Click on the pencil icon to edit preferences.

If you need no more than one group/currency, then uncheck the groups checkbox.  The whitelist checkbox determines whether new registrations require manual approval by a system administrator.  There are many other options here.

Also listed on the left admin panel are the data types which can be browsed, searched and edited.  In addition, there is a "Broadcast emails" link which allows an admin to send an email to those who are active and have allowed these emails in their settings.

In addition to configuration through the web admin interface, outgoing email configuration is done through environment variables including the following.
- SMTP_SERVER: if this is blank, the heroku install script will use the free sendgrid add-on
- SMTP_USER
- SMTP_PASSWORD
- SMTP_PORT: defaults to 587
- SMTP_DOMAIN: outgoing emails from the system will have this suffix in the from: field
- EXCEPTION_NOTIFICATION: a list of email addresses to notify when a code exception occurs


### How to get help
- [Google Group](http://groups.google.com/group/opensourcecurrency)
- [File an issue](https://github.com/oscurrency/oscurrency/issues)

### How to start for Developers
[Easy Developer Environment with Nitrous.IO](https://github.com/oscurrency/oscurrency/wiki/Easy-Developer-Environment-with-Nitrous.IO)

[Setting up development environment on Ubuntu](https://github.com/oscurrency/oscurrency/wiki/Setting-up-development-environment-on-ubuntu)

### APIs
- [Web Service API](https://github.com/oscurrency/oscurrency/wiki/Web-Service-API)
- [OpenTransact](http://opentransact.org)

### FAQs
[Configuration](https://github.com/oscurrency/oscurrency/wiki/Configuration)

[Privacy Considerations](https://github.com/oscurrency/oscurrency/wiki/Privacy-Considerations)

[A Very Important Note about the LICENSE](https://groups.google.com/forum/#!topic/opensourcecurrency/lvzRtLVwbXk)

### Insoshi Information

This is a forked repository. Have a look at [insoshi](https://github.com/insoshi/insoshi) for more information on the project this code is derived from.
