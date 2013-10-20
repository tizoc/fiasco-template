require './lib/fiasco/template'

Gem::Specification.new do |s|
  s.name              = 'fiasco-template'
  s.version           = Fiasco::Template::VERSION
  s.summary           = 'Templating engine inspired by Jinja2.'
  s.description       = 'Templating engine inspired by Jinja2.'
  s.authors           = ['Bruno Deferrari']
  s.email             = ['utizoc@gmail.com']
  s.homepage          = 'http://github.com/tizoc/fiasco-template'
  s.license           = 'MIT'
  s.files = Dir[
    'lib/**/*.rb'
  ]
  s.test_files = Dir[
    'test/**.rb',
    'test/**/*.html'
  ]
end
