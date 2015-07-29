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
require 'fcpm/ruby/ui'
require 'fcpm/ruby/cli'

Gem::BasicSpecification.send :prepend, FCPM::Ruby::CachedInstall
Bundler::Source::Rubygems.send :prepend, FCPM::Ruby::FetchPrecompiledGem
Bundler::GemInstaller.send :prepend, FCPM::Ruby::InstallPrecompiledGem

class Bundler::RubygemsIntegration
  def ui=(obj)
    # ignore attempts to change the UI object
  end
end

Gem::DefaultUserInteraction.ui = FCPM::Ruby::UI.new(STDIN, STDOUT, STDERR)
Bundler.ui = Bundler::UI::Silent.new
