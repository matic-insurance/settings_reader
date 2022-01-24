# SettingsReader

![Build Status](https://github.com/matic-insurance/settings_reader/workflows/ci/badge.svg?branch=main)
[![Test Coverage](https://codecov.io/gh/matic-insurance/settings_reader/branch/main/graph/badge.svg?token=5E8NA8EE8L)](https://codecov.io/gh/matic-insurance/settings_reader)

Settings Reader provides flexible way to make settings available for any application.

Settings are retrieved in 2 steps:
1. Get value from one of Backends (Yaml, KV storage, Database, etc)
2. Process value using one of Resolver (Environment variable, Erb template, Vault, etc)

Gem support any number of backends and resolvers. 
Such scheme allows customized and flexible settings for any environment. For example:
 - Read value in Consul, fallback to yaml, resolve via ERB for additional flexibility
 - Read value in Yaml for specific environment (local file), fallback to generic Yaml config, resolve in env when deployed 

The gem is built around an idea that having full set of settings in the repository allows any maintainer of app 
to better understand how it works. At the same time providing flexibility of where the settings will be retrieved/resolved
in the end environment (local dev machine, production instance, k8s pod).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'settings_reader'
```

## Initialization

At the load of application configure and load settings:

```ruby
APP_SETTINGS = SettingsReader.load('my_cool_app') do |config|
  # Configure backends.
  config.backends = [
    SettingsReader::Backends::YamlFile.new(Rails.root.join("config/settings/#{Rails.env}.yml")),
    SettingsReader::Backends::YamlFile.new(Rails.root.join('config/settings.yml'))
  ]
  # Configure resolvers.
  config.resolvers = [
    SettingsReader::Resolvers::Env.new,
    SettingsReader::Resolvers::Erb.new
  ]
end
```

**NOTE** For rails you can add this code to as initializer `settings_reader.rb` in `app/config/initializers`

## Usage
### Example settings structure

Assuming your defaults settings file in repository `config/settings.yml` looks like:
```yaml
my_cool_app:
  app_name: 'MyCoolApp'
  url: 'http://localhost:3001'
  
  integrations:
    database:
      domain: localhost
      user: app
      password: password1234
      parameters:
        pool: 20
        ssl: false
```

And production config `config/settings/produciton.yml` has following values
```yaml
my_cool_app:
  url: 'https://mycoolapp.com'

  integrations:
    database:
      domain: 10.0.5.141
      password: 'env://DATABASE_PASSWORD'
```

### Get setting via full path

Anywhere in your code base, after initialization, you can use
previously loaded settings to query any key by full path

```ruby
APP_SETTINGS['app_name']                          # "MyCoolApp"
APP_SETTINGS.get(:hostname)                       # "https://mycoolapp.com"

APP_SETTINGS.get('integrations/database/user')    # "app"
APP_SETTINGS['integrations/database/password']    # Value of environment variable DATABASE_PASS

#if you try to get sub settings via get - error is raised
APP_SETTINGS.get('integrations/database')         # raise SettingsReader::Error
```

**IMPORTANT** If you try to get settings tree via `get` method `SettingsReader::Error` is going to be raised. 
This is done due to the fact that we need to resolve settings every time they are requested. 
Resolving whole tree upfront is not possible as gem is not aware about final structure of all backends  

### Sub settings

Assuming some part of your code needs to work with smaller part of settings -
gem provides interface to avoid repeating absolute path

```ruby
# You can load sub settings from root object
db_settings = APP_SETTINGS.load('integrations/database') # SettingsReader::Reader
db_settings.get(:domain)                                 # "10.0.5.141"
db_settings['user']                                      # "app"
db_params = db_settings.load('parameters')               # SettingsReader::Reader
```

## Advanced Configurations & Customization

### Backends
Backends controls how and in which order settings are retrieved. 
During initial load - provide list of backend instances you want to query on all requests.

When application asks for specific setting - gem asks every backend in order of the configuration
until one returns not nil value. Full path to the setting provided to backend 

Default order for providers is:
1. `SettingsReader::Backends::YamlFile.new('config/app_settings.local.yml')`
2. `SettingsReader::YamlFile.new('config/app_settings.yml')`

Additional backend plugins:
- [settings_reader-consul_backend]() - Implementation pending

Custom provider can be added as long as it support following interface:
```ruby
class CustomProvider
  # get value by full_path or return nil if missing
  def get(full_path)
  end
end 
```

### Resolvers
Once value is retrieved - it will be additionally processed by resolvers.
This allows for additional flexibility like resolving one specific value in external sources.

While every resolver can be implemented in a form of a provider - one will be limited by the structure of settings,
that other system might not be compatible with this.

When value is retrieved - gem finds **first** provider that can resolve value and resolves it.
Resolved value is returned to application.

Default list of resolvers:
- `SettingsReader::Resolvers::Env.new`
- `SettingsReader::Resolvers::Erb.new`

List of built in resolvers:
- `SettingsReader::Resolvers::Env` - resolves compatible value by looking up environment variable.
  Matching any value that starts with `env://`. Value like `env://TEST_URL` will be resolved as `ENV['TEST_URL']`
- `SettingsReader::Resolvers::Erb` - resolves value by rendering it via ERB if it contains ERB template.
  Matching any value that contains `<%` and `%>` in it. Value like `<%= 2 + 2 %>` will be resolved as `4`

Additional resolver plugins:
- [settings_reader-vault_resolver](https://github.com/matic-insurance/settings_reader-vault_resolver) - 
resolves compatible value by getting it from Vault. Matching any value that starts with `vault://`. 
Value like `vault://secret/my_app/secrets#foo` will be resolved in vault as `Vault.kv('secret').get('my_app/secrets')`
and attribute `foo` will be retrieved from the resolved secret.  

Custom resolver can be added as long as it support following interface:
```ruby
class CustomResolver
  # should return true if current value should be resolved
  def resolvable?(value, full_path)
  end
  
  # resolve value
  def resolve(value, full_path)
  end
end 
```

### Gem Configuration

You can configure gem while loading settings:
```ruby
APP_SETTINGS = SettingsReader.configure do |config|
  config.backends = []
  config.resolvers = []
end
```

### Default gem configuration
Below is current default gem configuration
```ruby
APP_SETTINGS = SettingsReader.load do |config|
  config.backends = [
    SettingsReader::Backends::YamlFile.new('config/app_settings.local.yml'),
    SettingsReader::Backends::YamlFile.new('config/app_settings.yml')
  ]
  config.resolvers = [
    SettingsReader::Resolvers::Env.new,
    SettingsReader::Resolvers::Erb.new
  ]
end
```

## Development

1. Run `bin/setup` to install dependencies
1. Run tests `rspec`
1. Add new test
1. Add new code
1. Go to step 3
1. Create PR

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/matic-insurance/settings_reader. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/matic-insurance/settings_reader/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SettingsReader project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/matic-insurance/settings_reader/blob/master/CODE_OF_CONDUCT.md).
