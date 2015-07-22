module FCPM
  module Ruby

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

  end
end
