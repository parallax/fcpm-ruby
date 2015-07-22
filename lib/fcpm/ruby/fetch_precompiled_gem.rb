require 'rubygems/package'

module FCPM
  module Ruby

    module FetchPrecompiledGem

      def fetch_gem(spec)
        if !spec.cached_file_exists? && FCPM::Ruby.config['source']
          uri = URI.parse(File.join(FCPM::Ruby.config['source'], spec.explicit_file_name))

          begin
            body = _read_from_uri(uri)
            cache_dir = File.dirname(spec.cached_file)
            FileUtils.mkdir_p(cache_dir)
            File.open(spec.cached_file, "wb") { |f| f.write(body) }
          rescue OpenURI::HTTPError, Errno::ENOENT
            puts "no remote cached instance at #{uri}"
          end
        end

        if spec.cached_file_exists?
          _extract_gem(spec.cached_file, spec, File.join(Gem.dir, "cache"))
        else
          super
        end
      end

      def _read_from_uri(uri)
        if uri.respond_to?(:read)
          uri.read
        elsif uri.scheme == "file"
          File.read(uri.path)
        else
          raise NotImplementedError, "can't read from #{uri}"
        end
      end

      def _extract_gem(package, spec, destination)
        gem_file = "#{spec.full_name}.gem"
        gem_path = File.join(destination, gem_file)

        File.open(package, "rb") do |io|
          Zlib::GzipReader.wrap(io) do |gz|
            Gem::Package::TarReader.new(gz) do |tar|
              tar.seek(File.join("cache", gem_file)) do |gem|
                File.open(gem_path, "wb") { |f| f.write(gem.read) }
                File.chmod(gem.header.mode, gem_path)
              end
            end
          end
        end

        gem_path
      end

    end

  end
end
