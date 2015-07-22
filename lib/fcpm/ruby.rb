require 'bundler'
require 'yaml'

module FCPM
  module Ruby

    def self.config
      @config ||= YAML.load_file(".fcpm-ruby-config") rescue {}
    end

  end
end

require 'fcpm/ruby/cached_install'
require 'fcpm/ruby/fetch_precompiled_gem'
require 'fcpm/ruby/install_precompiled_gem'

Gem::BasicSpecification.send :prepend, FCPM::Ruby::CachedInstall
Bundler::Source::Rubygems.send :prepend, FCPM::Ruby::FetchPrecompiledGem
Bundler::GemInstaller.send :prepend, FCPM::Ruby::InstallPrecompiledGem
