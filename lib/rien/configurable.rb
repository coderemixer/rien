# frozen_string_literal: true

require 'tmpdir'

module Rien
  module Configurable
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def config
        @config ||= Configuration.new
      end

      def configure
        yield(config)
      end
    end

    class Configuration
      attr_accessor :includes, :excludes, :output, :tmpdir, :silent

      def initialize
        @includes = ['**/*']                            # include all paths by default
        @output = 'rien_output'                         # final result
        @tmpdir = File.expand_path('rien', Dir.tmpdir)  # store intermediate results
        @silent = false                                 # see cli.rb wait_user_on_encoded
      end

      def effective_paths
        temp_paths = []         # store ruby files and directories
        effective_paths = []    # only ruby files to be compiled

        @includes.each do |path|
          path = "./#{path}"
          temp_paths += Dir[path]
        end

        unless excludes.nil?
          @excludes.each do |path|
            path = "./#{path}"
            temp_paths -= Dir[path]
          end
        end

        temp_paths.each do |path|
          effective_paths.push(path) unless File.directory?(path) || path.match('Rienfile')
        end

        effective_paths
      end
    end
  end
end

module Rien
  include Rien::Configurable
end
