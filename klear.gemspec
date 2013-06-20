# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'klear/version'

Gem::Specification.new do |s|
  s.name        = 'klear'
  s.version     = Klear::VERSION
  s.date        = Klear::DATE
  s.authors     = ['art+com/dirk luesebrink']
  s.email       = ['dirk.luesebrink@artcom.de']
  s.homepage    = 'http://www.artcom.de/en/projects/project/detail/manta-rhei/'
  s.summary     = 'create and manage choreographies for motors and lights on the Manta Rhei'
  s.description = %q{ 
    create and manage choreographies for motors and lights on the Manta Rhei.
    klear is the kinetic-light-engine archive format and is used by the
    kinetic-light-engine runtime to drive the Manta Rhei installation.
  }
  s.add_dependency 'applix'
  s.add_dependency 'rubyzip'
  s.add_dependency 'bindata'

  s.add_development_dependency 'rspec'
  #s.add_development_dependency 'rspec-mocks'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  #s.add_development_dependency 'growl'
  #s.add_development_dependency 'ruby-prof'
  s.add_development_dependency 'rb-fsevent', '~>0.9.1'

  if RUBY_PLATFORM.match /java/i
    #s.add_development_dependency 'ruby-debug'
  else
    s.add_development_dependency 'debugger'
  end

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map do |f| 
    File.basename(f)
  end
  s.require_paths = ["lib"]
end
