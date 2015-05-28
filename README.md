# RelateIQ Ruby SDK 
[![Gem Version](https://img.shields.io/gem/v/riq.svg)](http://badge.fury.io/rb/riq)
[![Build Status](https://img.shields.io/travis/relateiq/ruby-sdk.svg)](https://travis-ci.org/relateiq/ruby-sdk)


A full featured API interface for interacting with the [RelateIQ](https://relateiq.com) API. 

## Status

|Badge (click for more info)|Explanation|
|---|---|
|[![](https://img.shields.io/badge/documentation-100%25-brightgreen.svg)](http://www.rubydoc.info/gems/riq)|% of methods documented|
|[![Code Climate](https://img.shields.io/codeclimate/coverage/github/relateiq/ruby-sdk.svg)](https://codeclimate.com/github/relateiq/ruby-sdk/coverage)|% of methods tested|
|[![Code Climate](https://img.shields.io/codeclimate/github/relateiq/ruby-sdk.svg)](https://codeclimate.com/github/relateiq/ruby-sdk/code)|Overall code quality (4.0 is best)|
|[![Gemnasium](https://img.shields.io/gemnasium/relateiq/ruby-sdk.svg)](https://gemnasium.com/relateiq/ruby-sdk)|Dependency freshness|
|[![MIT license](http://img.shields.io/badge/license-MIT-blue.svg)](http://opensource.org/licenses/MIT)|What can you use this for?|


## Code Examples

    require 'riq'
    RIQ.init(ENV['RIQ_API_KEY'], ENV['RIQ_API_SECRET'])

    # Contacts
    RIQ.contacts.each do |c|
        # do something
        puts c.name
    end
    # => Bruce Wayne
    # => Malcolm Reynolds
    # => Michael Bluth
    # => Tony Stark
    ...

    # Etc


## Helpful Links

* [Full ruby docs](http://www.rubydoc.info/gems/riq)
* [Examples and API docs](https://api.relateiq.com/#/ruby)
