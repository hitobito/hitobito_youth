# encoding: utf-8

$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your wagon's version:
require 'hitobito_youth/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  # rubocop:disable SingleSpaceBeforeFirstArg
  s.name        = 'hitobito_youth'
  s.version     = HitobitoYouth::VERSION
  s.authors     = ['Pascal Simon']
  s.email       = ['simon@puzzle.ch']
  s.homepage    = 'https://github.com/hitobito/hitobito_youth'
  s.summary     = 'Hitobito Youth Wagon'
  s.description = 'Provides fields required for J+S and BSV as well as corresponding reports.'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['Rakefile']
  s.test_files = Dir['spec/**/*']
  # rubocop:enable SingleSpaceBeforeFirstArg
end
