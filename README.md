# QuickApi

QuickApi is a simple bunch of Helpers in your models that helps you configure your default JSON, for each model with a high level of configuration.

## Installation

Add this line to your application's Gemfile:

    gem 'quick_api'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install quick_api

## Usage

### ORM
#### Mongoid
To use QuickApi in your Mongoid models:
```ruby
  class User
    include Mongoid::Document
    include QuickApi::Mongoid
  end
```

### Quick Start

A Model Example:

```ruby
  class User
    include Mongoid::Document
    include QuickApi::Mongoid

    field :name,        type: String
    field :username,    type: String
    field :email,       type: String
    field :password,    type: String

    has_many  :posts

    quick_api_attributes  :name, :usename, :email
    quick_api_has_many    :posts  # Must include QuickApi too
  end

  user = User.create(name: "SternCode", username: "sterncode", email: "sterncode@gmail.com")
  user.to_api
  => { name: "SternCode", username: "sterncode", email: "sterncode@gmail.com", posts: [{},{},{},{}] }
```

A Controller response example:

```ruby
  class UsersController < ApplicationController
    respond_to :json

    def show
      [...]
      rener json: @user.to_api, status: 200
    end
    
  end
```
### Working with QuickApi
QuickApi includes some helpers to your model, this is the list of them:

With ActiveRecord:

* quick_api_attributes
* quick_api_methods
* quick_api_has_many
* quick_api_belongs_to
* quick_api_has_one
* quick_api_has_and_belongs_to_many

With Mongoid:

Same as ActiveRecord an these 3 more:

* quick_api_embeds_many
* quick_api_embedded_in
* quick_api_embeds_one

Each of this helpers is useful for defining the attributes and relations that your Model may have.

#### Defaults
##### Attributes

To specify which attributes you want to be used when calling ```.to_api``` to the model you can use:

* quick_api_attributes

Example:

```ruby
  class User
    include Mongoid::Document
    include QuickApi::Mongoid

    field :name,        type: String
    field :username,    type: String
    field :email,       type: String

    quick_api_attributes  :name, :usename, :email
  end
```

With this you say that, when calling ```user.to_api``` it will return a hash of attributes like this: ```{ name: "", username: "", email: ""}```

#### Override the Defaults

If you want you can override the defaults definitions in the model at the time you call ```.to_api``` on it, by passing some parameters to it.

If you just call ```.to_api``` it will return the definition on the model.

If you pass some parameters to it, this will automatically override the defaults of the model:

* added
* fields

##### Added

This is the only one that **don't overrides all the defaults**, only add one more key|value field to the HASH:

```ruby
  class User
    include Mongoid::Document
    include QuickApi::Mongoid

    field :name,        type: String
    field :surname,     type: String

    has_many  :posts

    quick_api_attributes  :name, surname
  end

  user.to_api(added: [username: "Pepito", email: "pepito@gmail.com"])
  => { name: "", surname: "", username: "Pepito", email: "pepito@gmail.com"] }
```

##### Fields

If you specify the Fields then all the quick\_api\_\* definitions won't show.

```ruby
  class User
    include Mongoid::Document
    include QuickApi::Mongoid

    field :name,        type: String
    field :surname,     type: String

    has_many  :posts

    quick_api_attributes  :name, surname
    quick_api_has_many  :posts
  end

  user.to_api(fields: [email: "pepito@gmail.com"])
  => { email: "pepito@gmail.com" }
```

##### Options

With this you can change the default behavior when calling the ```.to_api()``` at the Model.

At the momnet we only support **relations**. With this you specify if you want to use the relations you specify in the model or not.

```ruby
  class User
    include Mongoid::Document
    include QuickApi::Mongoid

    field :name,        type: String
    field :surname,     type: String

    has_many  :posts, :phone_numbers
    beongs_to :city
    has_one   :wallet

    quick_api_attributes  :name, surname
    quick_api_has_many    :posts
    quick_api_has_one     :wallet

  end

  user.to_api(options: [relations: false])
  => { name: "", surname: ""}
```
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
