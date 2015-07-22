require 'net/scp'
require 'open-uri'

module FCPM
  module Ruby

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

          _push_build_to_host(spec.cached_file)
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

      def _push_build_to_host(filename)
        host = FCPM::Ruby.config['host'] or return
        uri = URI.parse(host)

        case uri.scheme
        when "file" then _push_build_to_file_host(uri, filename)
        when "scp"  then _push_build_to_scp_host(uri, filename)
        else raise "unsupported host scheme: #{uri}"
        end
      end

      def _push_build_to_file_host(uri, filename)
        FileUtils.mkdir_p(uri.path)
        FileUtils.cp(filename, uri.path)
      end

      def _push_build_to_scp_host(uri, filename)
        user = uri.user
        host = uri.host
        path = uri.path

        Net::SCP.upload!(host, user, filename, path,
          ssh: { keys: [ FCPM.config['key'] ],
                 verbose: :warn })
      end
    end

  end
end
