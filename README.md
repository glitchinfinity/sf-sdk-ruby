# sf-sdk-ruby
Ruby Wrapper around the site factory rest api
[![Coverage Status](https://coveralls.io/repos/github/acquia/sf-sdk-ruby/badge.svg?branch=master)](https://coveralls.io/github/acquia/sf-sdk-ruby?branch=master)

## Existing limitations

- SF Rest is a pretty thin wrapper around hte rest api and is relatively bumperless.

## Installation

Install the sfrest gem:

```shell
$ gem install sfrest
```
## Usage

```ruby
require 'sfrest'

sfapi = sfrest.new url, username, password
sfapi.site.site_list
```

## Contributing

See [contribute.md](contribute.md)