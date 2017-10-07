$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'friendly_id/json_translate/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'friendly_id-json_translate'
  s.version     = FriendlyId::JsonTranslate::VERSION
  s.authors     = ['Alexandre Ferraille']
  s.email       = ['alexandre.ferraille@gmail.com']
  s.homepage    = 'https://github.com/alexandre025/friendly_id-json_translate'
  s.summary     = 'Summary of FriendlyId::JsonTranslate.'
  s.description = 'Description of FriendlyId::JsonTranslate.'
  s.license     = 'MIT'

  s.files = Dir['lib']

  s.add_dependency 'friendly_id', '~> 5.2.0'
  s.add_dependency 'json_translate', '~> 3.0.0'

end
