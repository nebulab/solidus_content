
SolidusContent
==============

[![nebulab](https://circleci.com/gh/nebulab/solidus_content.svg?style=shield)](https://app.circleci.com/pipelines/github/nebulab/solidus_content)

Introduction goes here.

Installation
------------

Add solidus_content to your Gemfile:

```ruby
gem 'solidus_content'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bin/rails generate solidus_content:install
```

Usage
-----

Create an entry type for the home page:

```rb
home_entry_type = SolidusContent::EntryType.create!(
  name: :home,
  provider_name: :json,
  options: { path: 'data/home' }
)
```

Create a default entry for the home page:

```rb
home = SolidusContent::Entry.create!(
  entry_type: home_entry_type,
  slug: :default,
)
```

And then write a file inside your app root under `data/home/default.json`:

```json
{"title":"Hello World!"}
```

### Within an existing view

Use the content inside an existing view, e.g. `app/views/spree/home/index.html.erb`:

```erb
<% data = SolidusContent::Entry.data_for(:home, 'default') %>

<h1><%= data[:title] %></h1>
```

### With the default route

SolidusContent will add a default route that starts with `/c/`, by adding a view
inside `app/views/spree/solidus_content/` with the name of the entry type you'll
be able to render your content.

E.g. `app/views/spree/solidus_content/home.html.erb`:
```erb
<h1><%= @entry.data[:title] %></h1>
```

Then, visit `/c/home/default` or even just `/c/home` (when the content slug is
"default" it can be omitted).


### With a custom route

You can also define a custom route in your `Application` routes file and use
the `SolidusContent` controller to render your content from a dedicated view:

```rb
# config/routes.rb
Rails.application.routes.draw do
  # Will render app/views/spree/solidus_content/home.html.erb
  root to: 'spree/solidus_content#show', type: :home, id: :default

  # Will render app/views/spree/solidus_content/info.html.erb
  get "privacy", to: 'spree/solidus_content#show', type: :info, id: :privacy
  get "legal", to: 'spree/solidus_content#show', type: :info, id: :legal

  # Will render app/views/spree/solidus_content/post.html.erb
  get "blog/:id", to: 'spree/solidus_content#show', type: :post

  mount Spree::Core::Engine, at: '/'
end
```

Configuration
-------------

Configure SolidusContent in an initializer:

```rb
# config/initializers/solidus_content.rb

SolidusContent.configure do |config|
  # Your configuration goes here, please refer to the examples provided in the
  # initializer generated by `bin/rails g solidus_content:install`
end
```

Available Content Providers
---------------------------

### RAW

This is the most simple provider, its data will come directly from the entry
options.

```rb
posts = SolidusContent::EntryType.create(
  name: 'posts',
  provider_name: 'raw',
)
entry = SolidusContent::Entry.create(
  slug: '2020-03-27-hello-world',
  entry_type: posts,
  options: { title: "Hello World!", body: "My first post!" }
)
```

### JSON

Will fetch the data from a JSON file within the directory specified by the
`path` entry-type option and with a basename corresponding to the entry `slug`.

```rb
posts = SolidusContent::EntryType.create(
  name: 'posts',
  provider_name: 'json',
  options: { path: 'data/posts' }
)
entry = SolidusContent::Entry.create(
  slug: '2020-03-27-hello-world',
  entry_type: posts,
)
```

```jsonc
// [RAILS_ROOT]/data/posts/2020-03-27-hello-world.json
{"title": "Hello World!", "body": "My first post!"}
```

_NOTE: Absolute paths are taken as they are and won't be joined to `Rails.root`._

### YAML

Will fetch the data from a YAML file within the directory specified by the
`path` entry-type option and with a basename corresponding to the entry `slug`.

If there isn't a file with the `yml` extension, the `yaml` extension will be tried.

```rb
posts = SolidusContent::EntryType.create(
  name: 'posts',
  provider_name: 'yaml',
  options: { path: 'data/posts' }
)
entry = SolidusContent::Entry.create(
  slug: '2020-03-27-hello-world',
  entry_type: posts,
)
```

```yaml
# [RAILS_ROOT]/data/posts/2020-03-27-hello-world.yml

title: Hello World!
body: My first post!
```

_NOTE: Absolute paths are taken as they are and won't be joined to `Rails.root`._

### Solidus static content

To retrieve the page we have to pass the page `slug` to the entry options.
If the page slug is the same of the entry one, we can avoid passing the options.

```rb
posts = SolidusContent::EntryType.create(
  name: 'posts',
  provider_name: 'solidus_static_content'
)

entry = SolidusContent::Entry.create!(
  slug: '2020-03-27-hello-world',
  entry_type: posts,
  options: { slug: 'XXX' } # Can be omitted if the page slug is the same of the entry
)
```

_Be sure to have added `gem "solidus_static_content"` to your Gemfile._

### Contentful

To fetch the data we have to create a connection with Contentful passing the
`contentful_space_id` and the `contentful_access_token` to the entry-type options.

Will fetch the data from Contentful passing the `entry_id` entry option.

```rb
posts = SolidusContent::EntryType.create(
  name: 'posts',
  provider_name: 'contentful',
  options: {
    contentful_space_id: 'XXX',
    contentful_access_token: 'XXX'
  }
)

entry = SolidusContent::Entry.create!(
  slug: '2020-03-27-hello-world',
  entry_type: posts,
  options: { entry_id: 'XXX' }
)
```

_Be sure to have added `gem "contentful"` to your Gemfile._

### Prismic

To fetch the data we have to create a connection with Prismic passing the
`api_entry_point` to the entry-type options.

If the repository is private, you have to also pass the `api_token` to the entry-type options.

Will fetch the data from Prismic passing the `id` entry option.

```rb
posts = SolidusContent::EntryType.create(
  name: 'posts',
  provider_name: 'prismic',
  options: {
    api_entry_point: 'XXX',
    api_token: 'XXX' # Only if the repository is private
  }
)

entry = SolidusContent::Entry.create!(
  slug: '2020-03-27-hello-world',
  entry_type: posts,
  options: { id: 'XXX' }
)
```

_Be sure to have added `gem "prismic.io"` to your Gemfile._

### Renderful

The [Renderful](https://github.com/nebulab/renderful) provider works a bit differently from other
providers because of how Renderful is configured.

The provider is not registered by default, and you'll have to register it manually by passing your
Renderful instance:

```ruby
# [RAILS_ROOT]/config/initializers/solidus_content.rb

require 'solidus_content/providers/renderful'

renderful = Renderful::Client.new(...)

SolidusContent.config.register_provider(
  :renderful_contentful,
  SolidusContent::Providers::Renderful.new(renderful),
)
```

Once configured, you'll be able to use it like all other providers:

```ruby
posts = SolidusContent::EntryType.create(
  name: 'posts',
  provider_name: 'renderful_contentful',
)

entry = SolidusContent::Entry.create!(
  slug: '2020-03-27-hello-world',
  entry_type: posts,
  options: { id: 'XXX' }
)
```

*Unlike other providers,* however, Renderful will not pass the raw entity fields to your view.
Instead, you will get a `:render_in` proc that you should call with your view context. The call
will be forwarded to Renderful, which will render your content:

```erb
<%= @entry.data[:render_in].(self) %>
```

Registering a content provider
==============================

To register a content-provider, add a callable to the configuration under the
name you prefer. The

```rb
SolidusContent.config.register_provider :json, ->(input) {
  dir = Rails.root.join(input.dig(:type_options, :path))
  file = dir.join(input[:slug] + '.json')
  data = JSON.parse(file.read, symbolize_names: true)

  input.merge(data: data)
}
```

The `input` passed to the content-provider will have the following keys:

- `slug`: the slug of the content-entry
- `type`: the name of the content-type
- `provider`: the name of the content-provider
- `options`: the entry options
- `type_options`: the content-type options

The `output` of the content-provider is the `input` hash augmented with the
following keys:

- `data`: the content itself
- `provider_client`: (optional) the client of the external service
- `provider_entry`: (optional) the object retrieved from the external service

In both the input and output all keys should be symbolized.

Connecting Webhooks
===================

Many content providers such as Contentful or Prismic can send payloads via webhooks when content changes, those can be very useful in a number of ways.

We suggest using the [`solidus_webhooks`](http://github.com/solidusio-contrib/solidus_webhooks#readme) extension to get the most out of `solidus_content`, let's see some examples.

Add this to your Gemfile:

```rb
gem "solidus_webhooks"
```


### Using Webhooks to Auto-Create entries

In this example we setup a webhook that will create or update Contentful entries whenever they're changed or created.

```rb
# config/initializers/webhooks.rb

SolidusWebhooks.config.register_webhook_handler :contentful, -> payload {
  next unless payload.dig(:sys, :Type) == "Entry"
  entry_type = SolidusContent::EntryType.find_or_create_by(
    name: payload.dig(:sys, :ContentType, :sys, :id),
    provider_name: :raw
  )
  entry = entry_type.entries.find_or_initialize_by(slug: payload.dig(:sys, :id))
  entry.options = payload.fetch(:fields)
}
```

### Using Webhooks to expire caches

When caching the content of `app/views/spree/home/index.html.erb` as in this example:

```erb
<% cache(@entry) do %>
  <h1><%= @entry.data[:title] %></h1>
<% end %>
```

You may want to setup a webhook that will touch the entry every time it's modified:

```rb
# config/initializers/webhooks.rb

SolidusWebhooks.config.register_webhook_handler :prismic, -> payload {
  prismic_entry_types = SolidusContent::EntryType.where(provider_name: :prismic)

  # Prismic doesn't give much informations about which entries have been changed,
  # so we're touching them all.
  SolidusContent::Entry.where(entry_type: prismic_entry_types).touch_all
}
```

*NOTE: `touch_all` was introduced in Rails 6, for earlier versions use `find_each(&:touch)`.*

Testing
-------

First bundle your dependencies, then run `bin/rake`. `bin/rake` will default to building the dummy app if it does not exist, then it will run specs. The dummy app can be regenerated by using `bin/rake extension:test_app`.

```shell
bundle
bin/rake
```

To run [Rubocop](https://github.com/bbatsov/rubocop) static code analysis run

```shell
bundle exec rubocop
```

When testing your application's integration with this extension you may use its factories.
Simply add this require statement to your spec_helper:

```ruby
require 'solidus_content/factories'
```

Sandbox app
-----------

To run this extension in a sandboxed Solidus application you can run `bin/sandbox`
The path for the sandbox app is `./sandbox` and `bin/rails` will forward any Rails command
to `sandbox/bin/rails`.

Example:

```shell
$ bin/rails server
=> Booting Puma
=> Rails 6.0.2.1 application starting in development
* Listening on tcp://127.0.0.1:3000
Use Ctrl-C to stop
```

Releasing
---------

Your new extension version can be released using `gem-release` like this:

```shell
bundle exec gem bump -v VERSION --tag --push --remote upstream && gem release
```

Copyright (c) 2020 Nebulab, released under the New BSD License
