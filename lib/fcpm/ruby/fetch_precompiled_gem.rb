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

      def _read_from_uri(uri)
        if uri.respond_to?(:read)
          uri.read
        elsif uri.scheme == "file"
          File.read(uri.path)
        else
          raise NotImplementedError, "can't read from #{uri}"
        end
      end

    end

  end
end
