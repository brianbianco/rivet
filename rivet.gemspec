# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/',__FILE__)
$:.unshift lib unless $:.include?(lib)
require 'rivet/version'

Gem::Specification.new do |spec|
  spec.name        = 'rivet'
  spec.version     = Rivet::VERSION
  spec.licenses    = ['Apache2']
  spec.authors     = ['Brian Bianco']
  spec.email       = ['brian.bianco@gmail.com']
  spec.homepage    = 'http://www.github.com/brianbianco/rivet'
  spec.summary     = %q{A tool for managing autoscaling groups}
  spec.description = %q{Rivet allows you to define autoscaling groups and launch configurations as YAML and can SYNC that to AWS}

  spec.required_ruby_version     = '>= 1.9.1'
  spec.required_rubygems_version = '>= 1.3.6'

  spec.files = `git ls-files`.split($/)
  spec.test_files = spec.files.grep(%r{^spec/})

  spec.executables  = %w(rivet)
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk", "~> 1.24.0"
  spec.add_development_dependency "rake", ">= 10.1.0"
  spec.add_development_dependency "rspec", "~> 2.14.1"
end


