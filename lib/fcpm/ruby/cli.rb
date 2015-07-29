require 'bundler/cli'

module FCPM
  module Ruby
    class CLI < Bundler::CLI
      def initialize(*args)
        super
        Bundler.ui = Bundler::UI::Silent.new
      end
    end
  end
end
