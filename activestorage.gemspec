%w(models contollers helpers jobs).each do |dir|
  path = File.expand_path("../app/#{dir}", __FILE__)
  $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
end

require_relative "lib/active_storage/version"

Gem::Specification.new do |s|
  s.name     = "activestorage_legacy"
  s.version  = ActiveStorage.version
  s.authors  = "David Heinemeier Hansson"
  s.email    = "david@basecamp.com"
  s.summary  = "Attach cloud and local files in Rails applications"
  s.homepage = "https://github.com/iagopiimenta/activestorage_legacy"
  s.license  = "MIT"

  s.required_ruby_version = ">= 2.2.2"

  s.add_dependency "rails", ">= 3.2.22.4"
  s.add_dependency "sidekiq", ">= 4.2.0"
  s.add_dependency "marcel", ">= 1.0"

  s.files      = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- test/*`.split("\n")
end
