0.0.4 / 2012-01-31
==================

* Fixed bug that caused data pages (/log/:collection/:app) to not appear because CoffeeScript wasn't getting loaded quick enough. At some point, the app should only send JS to the client.
* Updated README.
* Changed default `development` and `production` databases.

0.0.3 / 2012-01-31
==================

* Forgot to add Express.js package.json as a dependency
* Forgot to add Jade to package.json dependency
* Fixed bug when specifiying production env, loaded as development env
* Cleaned up layout.jade
* I thought the Date getTime() returned millis since Unix epoch in your time zone. Removed time zone conversion.
* Cleaned date/time string. It was too long.
* Doesn't just accept JSON, now accepts simple strings as data. 
* Removed Request as dependency. Uses SuperAgent now.
* Refactored app.test.coffee, now use beforeEach()/afterEach()
* Changed route log/data/:collection/:app/ to the more intuitive log/:collection/:app/data.json

0.0.2 / 2012-01-30
==================

* Added command line option to specify configuration file
* Fixed bug that would prevent app.test.html from loading
* Created `logmeup` script

0.0.1 / 2012-01-27
==================

* Initial public release