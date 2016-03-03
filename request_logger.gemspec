Gem::Specification.new do |s|
  s.name = 'request_logger' 
  s.summary = 'summary tbd'
  s.version = "0.0.5"
  s.date = '2016-03-01'
  s.authors = ['Robby Ranshous', 'Lindsay Weil', 'Chris Jordan']
  s.files = [
    "lib/request_logger.rb"
  ]
  s.require_paths = ["lib"]
  s.add_runtime_dependency "logging"
  s.add_development_dependency "rspec", ['~> 3.1.0']
end
