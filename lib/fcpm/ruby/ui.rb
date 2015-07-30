require 'rubygems/user_interaction'

module FCPM
  module Ruby
    class UI < Gem::StreamUI
      class BackendProgressReporter
        attr_accessor :total

        def initialize(out_stream, size, prefix, *args)
          @out = out_stream
          @total = size
          @count = 0
          @prefix = prefix
          _print_progress
        end

        def updated(*args)
          @count += 1
          _print_progress
        end

        def done
          _print_progress
        end

        def _print_progress
          @out.puts "progress|#{@prefix}|#{@count}|#{@total}"
          @out.flush
        end
      end

      class BackendDownloadReporter
        attr_reader :file_name
        attr_reader :total_bytes
        attr_reader :progress

        def initialize(out_stream, *args)
          @out = out_stream
          @progress = 0
        end

        def fetch(file_name, total_bytes)
          @file_name = file_name
          @total_bytes = total_bytes.to_i
          _print_progress
        end

        def update(bytes)
          @progress = bytes
          _print_progress
        end

        def done
          @progress = @total_bytes
          _print_progress
        end

        private

        def _print_progress
          @out.puts "download|#{@file_name}|#{@progress}|#{@total_bytes}"
          @out.flush
        end
      end

      def tty?
        false
      end

      def say(statement)
        @outs.puts "say|#{statement}"
      end

      def alert(statement, question=nil)
        @outs.puts "info|#{statement}"
      end

      def alert_warning(statement, question=nil)
        @errs.puts "warn|#{statement}"
      end

      def alert_error(statement, question=nil)
        @errs.puts "error|#{statement}"
      end

      def progress_reporter(*args)
        BackendProgressReporter.new(@outs, *args)
      end

      def download_reporter(*args)
        BackendDownloadReporter.new(@outs, *args)
      end
    end
  end
end
