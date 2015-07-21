require 'bundler'
require 'yaml'
require 'open-uri'

module FCPM

  def self.config
    @config ||= YAML.load_file(".fcpm-ruby-config") rescue {}
  end

  module CachedInstall

    def explicit_name
      saved_platform, self.platform = self.platform, Gem::Platform.local
      full_name
    ensure
      self.platform = saved_platform
    end

    def explicit_file_name
      explicit_name + ".tar.gz"
    end

    def cached_file
      File.join(Gem.dir, "cache", explicit_file_name)
    end

    def cached_file_exists?
      File.exists?(cached_file)
    end

  end

  module FetchPrecompiledGem

    def fetch_gem(spec)
      if !spec.cached_file_exists? && FCPM.config['source']
        uri = URI.parse(File.join(FCPM.config['source'], spec.explicit_file_name))

        begin
          body = uri.read
          cache_dir = File.dirname(spec.cached_file)
          FileUtils.mkdir_p(cache_dir)
          File.open(spec.cached_file, "wb") { |f| f.write(body) }
        rescue OpenURI::HTTPError
          puts "no remote cached instance at #{uri}"
        end
      end

      if spec.cached_file_exists?
        # extract gem file from cached install
        system("tar -xzf #{spec.cached_file} -C #{Gem.dir} cache/#{spec.full_name}.gem")
        File.join(Gem.dir, "cache", spec.full_name + ".gem")
      else
        super
      end
    end

  end

  module InstallPrecompiledGem

    def install
      if !spec.cached_file_exists?
        old_install_dir = @install_dir
        old_gem_home = @gem_home

        temp_path = "/tmp/fcpm-ruby-#{spec.name}.build"
        FileUtils.rm_rf(temp_path)
        FileUtils.mkdir_p(temp_path)

        @install_dir = @gem_home = temp_path
        super
        @install_dir, @gem_home = old_install_dir, old_gem_home

        cache_dir = File.dirname(spec.cached_file)
        FileUtils.mkdir_p(cache_dir)
        system "tar -czf #{spec.cached_file} -C #{temp_path} ."
        FileUtils.rm_rf(temp_path)
      end

      if spec.cached_file_exists?
        FileUtils.mkdir_p(@install_dir)
        system "tar -xzf #{spec.cached_file} -C #{@install_dir}"
      else
        # FIXME: something went wrong?
        abort "something died?"
      end

      spec
    end

  end
end

Gem::BasicSpecification.send :prepend, FCPM::CachedInstall
Bundler::Source::Rubygems.send :prepend, FCPM::FetchPrecompiledGem
Bundler::GemInstaller.send :prepend, FCPM::InstallPrecompiledGem
