# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'elesai/version'
require 'elesai/about'

Gem::Specification.new do |s|
  s.name                      = Elesai::ME.to_s
  s.version                   = Elesai::VERSION
  s.platform                  = Gem::Platform::RUBY
  s.authors                   = "Gerardo López-Fernádez"
  s.email                     = 'gerir@evernote.com'
  s.homepage                  = 'https://github.com/evernote/ops-elesai'
  s.summary                   = "Wrapper for LSI's MegaCli utility"
  s.description               = "Elesai is a wrapper around LSI's MegaCli utility that provides access to common types of information about the RAID controllers. It also has Nagios plugin personalities"
  s.license                   = "Apache License, Version 2.0"
  s.required_rubygems_version = ">= 1.3.5"

  s.add_dependency('workflow')
  s.add_dependency('log4r')
  s.add_dependency('senedsa', '>= 0.2.5')

  s.files        = Dir['lib/**/*.rb'] + Dir['bin/*'] + %w(LICENSE README.md)
  s.executables  = %w(elesai check_elesai)
  s.require_path = 'lib'
end
