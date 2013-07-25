# encoding: UTF-8
$:.push File.expand_path("../lib", __FILE__)
require "zenpush/version"

Gem::Specification.new do |s|
  s.name        = "zenpush"
  s.version     = ZenPush::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nicolas Fouché"]
  s.email       = ["nicolas.fouche@cleverscale.com"]
  s.homepage    = "https://github.com/cleverscale/zenpush"
  s.summary     = "Push your markdown files to your Zendesk knowledge base"
  s.description = "Push your markdown files to your Zendesk knowledge base.  It will handle full and starter accounts."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.rdoc_options  = ["--charset=UTF-8"]

  s.add_dependency "boson", "~> 1.0" # Command line
  s.add_dependency "httparty", "~> 0.8.0" # Zendesk API calls
  s.add_dependency "redcarpet", "~> 2.1.0" # Markdown to HTML
  s.add_dependency "pygments.rb", "~> 0.4.2" # Code highlighting for Github flavored markdown
  s.add_dependency "awesome_print", "~> 1.0.0" # Colorized output of Zendesk responses
  s.add_dependency "json_pure", "~> 1.5.1" # The C-gem "json" will still be used instead if it's installed

  s.add_development_dependency "rake"
end
