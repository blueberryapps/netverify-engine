# Netverify API validation implementation for Rails

## Installation

TODO: Installation as gem

1. Mount engine to your `config/routes.rb`

```ruby
mount Netverify::Engine, at: 'netverify'
```

2. Install migrations of netverify

```console
rake netverify:install:migrations
rake db:migrate
```

3. In the model you want to validate (you can have more of them), add

```ruby
has_one :validation, as: :validatable, class: 'Netverify::Validation'
```

## Usage

### Basic usage - API

In your controller/wherever, call the instantiate the class and run
`perform!`

```ruby
# user is an instance the User model
user = User.first

# opts are all options, you can pass in as of Netverify integration
# guide version (v 1.7.3)
# all keys are handled as underscore (original
# merchantIdScanReference is merchant_id_scan_reference in gem)
opts = { merchant_id_scan_reference: '<your scan id reference>',
         frontside_image: '<image you want to validate>' }

validator = Netverify::ApiValidator.new(user, opts)
validator.perform!
```

### Basic usage - IFRAME

In your controller/wherever, call instantiate the class and run
`perform_initiation!`

After the user finishes uploading his documents, a simple GET request is
sent back to the site and renders in the iframe (mounted to
`/netverify/validations/{success,error}`).

There is a basic implementation of the success/error page, which you can
override by creating new view files in your application at
`app/views/netverify/validations/{success,error}.html.<whatever>`

```ruby
# user in an instance of the User model
user = User.first

# opts are all options, you can pass in as of Netverify integration
# guide (version 1.7.3)
opts = {
  merchant_id_scan_reference: '<your scan id reference>'
}

validator = Netverify::IframeValidator.new(user, opts)
validator.perform_initiation!
```

### Running callbacks

Netverify calls a callback (mounted to `/netverify/validations/callback`).
After the state has changed, a new callback is called and you can implement it
on the class (here `User`).

If you want to run a callback after the state has changed by Netverify,
you can do it the following way.

```ruby
class User < ActiveRecord::Base
  include Netverify::Callbacks

  after_netverify_state_changed :do_something

  private

  def do_something
    ...
  end
end
```
