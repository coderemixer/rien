require "optparse"
require "ruby-progressbar"
require "fileutils"

module Rien::CliHelper
  class CliHelperStatus
    attr_accessor :silent

    def initialize
      @silent = false
    end
  end

  private def status
    @status ||= CliHelperStatus.new
  end

  private def encoder
    @encoder ||= Rien::Encoder.new
  end

  private def wait_user_on_encoded(path)
    if path.match(".rbc") && !status.silent
      print "\n#{path} maybe have already been encoded, continue? (a/y/n) ".yellow
      user_input = STDIN.gets.chomp.downcase
      if user_input == "a"
        status.silent = true # skip all warnings
      elsif user_input == "y"
        # ignore
      else
        abort("Manually abort".red)
      end
    end
  end

  private def try_to_encode(path)
    wait_user_on_encoded(path)

    begin
      bytes = encoder.encode_file(path)
    rescue Exception => e
      abort "\nFailed to encode #{path}, reason:\n#{e.message}".red
    end

    bytes
  end

  private def export_single_encoded(source, output)
    bytes = try_to_encode(source)

    File.open("#{output}.rbc", "wb") do |f|
      f.write bytes
    end

    File.open(output, "w") do |f|
      f.write encoder.bootstrap
    end
  end

  private def replace_with_encoded(path)
    bytes = try_to_encode(path)

    # Write encoded file
    File.open("#{path}.rbc", "wb") do |f|
      f.write bytes
    end

    # Replace file with bootstrap
    FileUtils.rm(path)
    File.open(path, "w") do |f|
      f.write encoder.bootstrap
    end
  end

  private def pack_files(paths)
    progressbar = ProgressBar.create(:title => "Generating",
                                     :starting_at => 0,
                                     :length => 80,
                                     :total => paths.length,
                                     :smoothing => 0.6,
                                     :format => "%t |%b>>%i| %p%% %a")

    paths.each do |path|
      progressbar.log("Compiling: #{path}")
      replace_with_encoded(path) # Wirte encoded file and replace the orginal ruby source file with bootstrap
      progressbar.increment
    end
  end

  private def try_to_copy_directory(source, output)
    begin
      FileUtils.cp_r "#{source}/.", output
    rescue Exception => e
      abort("\nFailed to access #{output}, reason: #{e.message}".red)
    end
  end

  private def pack_all_files_in_directory(source, output)
    try_to_copy_directory(source, output)
    files = Dir["#{output}/**/*.rb"] # pack all files
    pack_files(files)
    puts "Successed to compile and pack #{source} into #{output}\ntotal #{files.length} file(s)".green
  end

  private def use_rienfile_to_pack(source)
    begin
      rienfile = "#{source}/Rienfile"
      load rienfile
    rescue Exception => e
      abort "\nFailed to load Rienfile, reason:\n#{e.message}".red
    end

    status.silent = Rien.config.silent
    output = Rien.config.output_path

    try_to_copy_directory(source, output)

    files = Rien.config.effective_paths
    pack_files(files)

    puts "Successed to compile and pack #{source} into #{output}\n" \
         "using #{rienfile}\n" \
         "total #{files.length} file(s)".green
  end

end

class Rien::Cli
  include Rien::CliHelper

  def initialize
    @options = {
      mode: :help,
    }

    @parser = OptionParser.new do |opts|
      opts.banner = "Usage: rien [options]"
      opts.on("-e", "--encode [FILE]", "Encode specific ruby file", String) do |v|
        @options[:mode] = :encode
        @options[:file] = v
        @options[:output] ||= "output.rb"
      end

      opts.on("-p", "--pack [DIR]", "Pack ruby directory into encoded files", String) do |v|
        @options[:mode] = :pack
        @options[:file] = v
        @options[:output] ||= "rien_output"
      end

      opts.on("-o", "--out [FILE/DIR]", "Indicate the output of the encoded file(s)", String) do |v|
        @options[:output] = v
      end

      opts.on("-u", "--use-rienfile", "Use Rienfile to configure, override other options", String) do
        @options[:rienfile] = true
      end

      opts.on("-s", "--silent-mode", "Suppress all prompts asking for user input", String) do
        @options[:silent] = true
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
      if use_rienfile
        use_rienfile_to_pack(source)
      else
        output = @options[:output]
        status.silent = @options[:silent]
        pack_all_files_in_directory(source, output)
      end
    when :help
      puts @parser
    else
      puts @parser
    end
  end
end
