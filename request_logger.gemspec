Gem::Specification.new do |s|
  s.name = 'request_logger' 
  s.summary = 'summary tbd'
  s.version = "0.0.3"
  s.date = '2014-11-04'
  s.authors = ['Robby Ranshous', 'Lindsay Weil']
  s.files = [
    "lib/request_logger.rb"
  ]
  s.require_paths = ["lib"]
  s.add_runtime_dependency "logging"
  s.add_development_dependency "rspec", ['=2.14.1']
end
