# [LogMeUp](http://logmeup.com)

Easily view your log files in one place. View this at [logmeup.com](http://logmeup.com).

## Value Proposition

Let's say that you have multiple servers and applications spread all over the cloud and your LAN. You are tired of constantly checking up on them. LogMeUp allows you to open up your web browser and easily view all of your log data in real-time (using websockets) in one place.



## About
LogMeUp is software that you can use to monitor your log files. You can log data with any of the supported language plugins or write your own plugin to its REST interface. You'll then be able to see your logs real-time in the browser. 

**_NOTE:_** At this time, since the application doesn't have any authentication mechanism, it should only be installed on your local network.



## Installation

### Requirements

1. Node.js v0.6.
2. MongoDB. Any version of MongoDB that supports `capped collections` should work.

Since LogMeUp is an app that runs on Node.js, the easiest way to install it is via `npm`. Downloadable packages may be provided in the future. 




### Installing Requirements (Mac OS X)

To install Node.js on Mac OS X, you can use [Homebrew](homebrew) or install [NVM](nvm). If you ever want to switch Node.js versions, you should use NVM.

Homebrew:

    brew install node

NVM:

    nvm install v0.6.9
    nvm use v0.6.9

To install MongoDB on Mac OS X, use Homebrew.

Homebrew:

    brew install mongodb



### Installing Requirements (Linux)

To install Node.js on Linux, you should just use NVM.

    nvm install v0.6.9
    nvm use v0.6.9

To install MongoDB on Linux:

* [Ubuntu](http://procbits.com/2011/05/04/installing-mongodb-1-8-1-on-ubuntu-10-04-lts/)
* [Redhat/Fedora/Centos](http://www.if-not-true-then-false.com/2010/install-mongodb-on-fedora-centos-red-hat-rhel/)
   



### Installing LogMeUp (Linux/OS X)

_Windows hasn't been untested._

After Node.js is installed:

    npm install logmeup-server



## Usage

To run LogMeUp, navigate to the installation directory, and run:

    bin/logmeup
  
LogMeUp has a concept called `collections` and `apps`. Collections are **not** the same as MongoDB collections. Collections are just a logical grouping of log files. Apps just represent a log file.

Let's say that you're doing some consulting work for **SpongeBob Software Inc**. SpongeBob Software Inc has hired you to help them with build two software packages. One is called **Super Invoices** and the other is called **Time Tracker**. You might make a collection named _spongebobsoftware_ and apps named _superinvoices_ and _timetracker_. You could then view the log data at http://yourserver.com:7070/log/spongebogsoftware/timetracker and http://yourserver.com:7070/log/spongebogsoftware/superinvoices.


### Configuration

The default configuration file is placed in the installation directory `config` folder. It looks like:

```coffeescript
module.exports = 
  defaultenv: 'development'
  port: 7070
  recordsPerPage: 100
  database:
    development:
      name: 'logmeup_development'
      host: '127.0.0.1'
      port: 27017
    testing:
      name: 'logmeup_testing'
      host: '127.0.0.1'
      port: 27017
    production:
      name: 'logmeup_production'
      host: '127.0.0.1'
      port: 27017
```

You can store this in another location if you choose, like `/etc/logmeup.conf`. To do this, you pass the `-f` or `--config` flag.

Example:

    bin/logmeup --config /etc/logmeup.conf

You may want to force the `production` environment. This makes the app run much faster. You can change the `defaultenv` in the config file to `production`. Or, you can run:

    NODE_ENV=production bin/logmeup [--config filename]


## Development

### Technologies Used

LogMeUp is a Node.js app built with the following modules:

* Express.js
* Jade
* Socket.io
* MongoDB-Native
* SuperAgent
* Mocha



### Available Libraries

* [Node.js](https://github.com/jprichardson/node-logmeup): `npm install logmeup`
* C# (Coming soon)
* Ruby (Coming soon)



### REST API

LogMeUp has a very simple REST API. It **will always return a HTTP status code of 200**. This is because some libraries will throw exceptions on status codes such as 4** or 5**. You will need to see if the response body text starts with 'Error'.



#### Create collection/app

`PUT http://yourserver.com:7070/log/:collection/:app`

Example:

    CURL -X PUT http://yourserver.com:7070/log/mycompany/mycoolapp

Success Output:

    Created: mycompany_mycoolapp

Error Output:

    Error: (Error Message)



#### Delete collection/app

`DELETE http://yourserver.com:7070/log/:collection/:app`

Example:

    CURL -X DELETE http://yourserver.com:7070/log/mycompany/mycoolapp

Success Output:

    Deleted: mycompany_mycoolapp

Error Output:

    Error: (Error Message)
   


#### Show web page for collection/app

`GET http://yourserver.com:7070/log/:collection/:app`

Example:

    CURL -X GET http://yourserver.com:7070/log/mycompany/mycoolapp

or in your browser…

	http://yourserver.com:7070/log/mycompany/mycoolapp

Success Output:

    (Page HTML)

Error Output:

    Error: (Error Message)



#### Show JSON data for collection/app

`GET http://yourserver.com:7070/log/:collection/:app/data.json`

Example:

    CURL -X GET http://yourserver.com:7070/log/mycompany/mycoolapp/data.json

or in your browser…

	http://yourserver.com:7070/log/mycompany/mycoolapp/data.json

Success Output:

    (JSON Data)

Error Output:

    Error: (Error Message)



#### Store JSON data for collection/app

`POST http://yourserver.com:7070/log/:collection/:app`

Example:

    CURL -X POST -d "JSON STRING HERE" -H "Content-Type:application/json" http://yourserver.com:7070/log/mycompany/mycoolapp

Success Output:

    Stored data.

Error Output:

    Error: (Error Message)



#### Store String data for collection/app

`POST http://yourserver.com:7070/log/:collection/:app`

**Note:** You must set the entire string to the `data` key. Your string must be URI encoded. 

String Example:

Let's say that you want to log the string `Are you there?`. Your url encoded string would then be: `data=Are%20you%20there%3F`. These are not details that you need to worry about if you use a language specific driver. 

Example:

    CURL -X POST -d "URL ENCODED STRING HERE" -H "Content-Type:application/x-www-form-urlencoded" http://yourserver.com:7070/log/mycompany/mycoolapp

Success Output:

    Stored data.

Error Output:

    Error: (Error Message)




## Changelog

View here: https://github.com/jprichardson/logmeup-server/blob/master/CHANGELOG.md



## License

Afero GNU Publice License Version 3. See [LICENSE](license) for complete details.

Copyright (c) 2012 JP Richardson [Twitter](twitter) / [Google+](googleplus)

## Other

If you use Git, you should check out my startup [Gitpilot](gitpilot) to help make Git thoughtless.

[nvm]:https://github.com/creationix/nvm
[homebrew]:http://mxcl.github.com/homebrew/
[license]:https://github.com/jprichardson/logmeup-server/blob/master/LICENSE
[logmeup]:http://logmeup.com
[gitpilot]:http://gitpilot.com
[twitter]:http://twitter.com/jprichardson
[googleplus]:https://plus.google.com/u/0/117996975742030675047/posts 