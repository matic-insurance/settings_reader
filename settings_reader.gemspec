require_relative 'lib/settings_reader/version'

Gem::Specification.new do |spec|
  spec.name          = 'settings_reader'
  spec.version       = SettingsReader::VERSION
  spec.authors       = ['Volodymyr Mykhailyk']
  spec.email         = ['712680+volodymyr-mykhailyk@users.noreply.github.com']

  spec.summary       = 'Flexible Settings reader with support of custom backends and value resolutions'
  spec.description   = <<-DESCRIPTION
    Customizable 2 step setting reading for your application.

    First settings is retrieved from list of backends and afterwards processed 
    by the list of resolvers to allow even more flexibility.
  DESCRIPTION
  spec.homepage      = 'https://github.com/matic-insurance/settings_reader'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage.to_s

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'codecov', '~> 0.4'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.66'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.32.0'
  spec.add_development_dependency 'simplecov', '~> 0.16'
end
