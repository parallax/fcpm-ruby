require 'rubygems/package'
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

          _build_package(temp_path, spec.cached_file)
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

      def _build_package(root, target)
        dir = File.dirname(target)
        root = root + "/" unless root[-1] == "/"

        FileUtils.mkdir_p(dir)

        File.open(target, "wb") do |out|
          Zlib::GzipWriter.wrap(out, Zlib::BEST_COMPRESSION) do |gz|
            Gem::Package::TarWriter.new(gz) do |tar|

              stack = [root]
              while stack.any?
                path = stack.pop

                Dir.foreach(path) do |element|
                  next if element == '.' || element == '..'
                  full = File.join(path, element)

                  if File.directory?(full)
                    stack.push(full)
                  else
                    stat = File.stat(full)
                    name = full[root.length..-1]
                    tar.add_file_simple(name, stat.mode, stat.size) do |io|
                      io.write(File.read(full))
                    end
                  end
                end

              end
            end
          end
        end
      end
    end

  end
end
