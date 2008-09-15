CalendarHelper
==============

A simple helper for creating an HTML calendar. The "calendar" method will be automatically available to your view templates.

There is also a Rails generator that copies some stylesheets for use alone or alongside existing stylesheets.

Authors
=======

Jeremy Voorhis -- http://jvoorhis.com
Original implementation

Geoffrey Grosenbach -- http://nubyonrails.com
Test suite and conversion to a Rails plugin

Contributors
============

* Jarkko Laine http://jlaine.net/
* Tom Armitage http://infovore.org
* Bryan Larsen http://larsen.st

Usage
=====

See the RDoc (or use "rake rdoc").

To copy the CSS files, use

  ./script/generate calendar_styles

CSS will be copied to subdirectories of public/stylesheets/calendar.

