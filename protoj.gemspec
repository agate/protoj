version = File.read(File.expand_path("../VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9.2'
  s.name                  = 'protoj'
  s.version               = version
  s.summary               = 'Definable JSON Object Builder'
  s.description           = 'Allows user to define a JSON\'s schema with ruby object.'
  s.license               = 'MIT'

  s.author                = 'Hao Hong'
  s.email                 = 'agate.hao@gmail.com'
  s.homepage              = 'http://honghao.me'

  s.files                 = Dir['CHANGELOG.md', 'MIT-LICENSE', 'README.md', 'lib/**/*']
  s.require_path          = 'lib'

  s.add_dependency('json', '~> 1.8.3')
  s.add_dependency('activesupport', '~> 4.1.11')
end
