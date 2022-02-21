source 'https://rubygems.org'

# Specify your gem's dependencies in barrage.gemspec
gemspec

if Gem::Version.create(RUBY_VERSION) < Gem::Version.create("2.2.2")
  gem "activesupport", "< 5.0.0"
end

if Gem::Version.create(RUBY_VERSION) < Gem::Version.create("2.2.3")
  gem "listen", "< 3.1.0"
end

if Gem::Version.create(RUBY_VERSION) < Gem::Version.create("2.2.5")
  gem "ruby_dep", "< 1.4.0"
end

gem "redis", ">= 4.0.0"
