# frozen_string_literal: true

module Rien
  class Cli
    include Rien::CliHelper

    def initialize
      @options = {
        mode: :help
      }

      @parser = OptionParser.new do |opts|
        opts.banner = 'Usage: rien [options]'
        opts.on('-e', '--encode [FILE]', 'Encode specific ruby file', String) do |v|
          @options[:mode] = :encode
          @options[:file] = v
          @options[:output] ||= 'output.rb'
        end

        opts.on('-p', '--pack [DIR]', 'Pack ruby directory into encoded files', String) do |v|
          @options[:mode] = :pack
          @options[:file] = v
          @options[:output] ||= 'rien_output'
          @options[:tmpdir] ||= '/tmp/rien'
        end

        opts.on('-o', '--out [FILE/DIR]', 'Indicate the output of the encoded file(s)', String) do |v|
          @options[:output] = v
        end

        opts.on('-u', '--use-rienfile', 'Use Rienfile to configure, override other options', String) do
          @options[:rienfile] = true
        end

        opts.on('-s', '--silent-mode', 'Suppress all prompts asking for user input', String) do
          @options[:silent] = true
        end

        opts.on('-t', '--tmpdir [DIR]', 'Select a temp directory to store intermediate results', String) do |v|
          @options[:tmpdir] = v
        end

        opts.on('-v', '--version', 'Show current version') do
          @options[:mode] = :version
        end
      end
    end

    def start
      @parser.parse!
      case @options[:mode]
      when :encode
        source = @options[:file]
        output = @options[:output]
        status.silent = @options[:silent]

        export_single_encoded(source, output)

        puts "Successed to compile #{source} into #{output} and #{output}.rbc".green
      when :pack
        source = @options[:file]
        abort("\nOnly directory can be packed".red) unless File.directory?(source)

        use_rienfile = @options[:rienfile]
        if use_rienfile # Ignore other options from CLI
          puts 'Use Rienfile'.green
          use_rienfile_to_pack(source)
        else # Use options from CLI
          output = @options[:output]
          tmpdir = @options[:tmpdir]
          status.silent = @options[:silent]

          pack_all_files_in_directory(source, output, tmpdir)
        end
      when :version
        puts Rien::VERSION.to_s
      else
        puts @parser
      end
    end
  end
end
