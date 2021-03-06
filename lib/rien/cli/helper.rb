# frozen_string_literal: true

module Rien
  module CliHelper
    class CliHelperStatus
      attr_accessor :silent

      def initialize
        @silent = false
      end
    end

    def self.make_failed_to_encode_error(path, reason)
      Rien::Error::FailedToEncode.new(path, reason)
    end

    def self.make_failed_to_move_error(path, reason)
      Rien::Error::FailedToMove.new(path, reason)
    end

    def self.make_failed_to_copy_error(path, reason)
      Rien::Error::FailedToCopy.new(path, reason)
    end

    def self.make_failed_to_load_rienfile_error(path, reason)
      Rien::Error::FailedToLoadRienfile.new(path, reason)
    end

    private

    def status
      @status ||= CliHelperStatus.new
    end

    def encoder
      @encoder ||= Rien::Encoder.new
    end

    def wait_user_on_encoded(path)
      return unless path.match('.rbc') && !status.silent

      path.match('.rbc') && !status.silent
      print "\n#{path} maybe have already been encoded, continue? (a/y/n) ".yellow
      user_input = $stdin.gets.chomp.downcase
      case user_input
      when 'a'
        status.silent = true # skip all warnings
      when 'y'
        # ignore
      else
        abort('Manually abort'.red)
      end
    end

    # Notice:
    # this path must be relative path,
    # or it would break after moving to another directory
    def encode(path)
      wait_user_on_encoded(path)

      begin
        bytes = encoder.encode_file(path)
      rescue SyntaxError => e
        raise Rien::CliHelper.make_failed_to_encode_error(path, e.message)
      end

      bytes
    end

    def export_single_encoded(source, output, mode: :plain)
      bytes = encode(source)

      File.open("#{output}.rbc", 'wb') do |f|
        f.write bytes
      end

      File.open(output, 'w') do |f|
        f.write encoder.bootstrap(mode: mode)
      end
    end

    def replace_with_encoded(path, mode: :plain)
      bytes = encode(path)

      # Write encoded file
      File.open("#{path}.rbc", 'wb') do |f|
        f.write bytes
      end

      # Replace file with bootstrap
      FileUtils.rm(path)
      File.open(path, 'w') do |f|
        f.write encoder.bootstrap(mode: mode)
      end
    end

    def pack_files(paths, mode: :plain)
      progressbar = ProgressBar.create(title: 'Generating',
                                       starting_at: 0,
                                       length: 80,
                                       total: paths.length,
                                       smoothing: 0.6,
                                       format: '%t |%b>>%i| %p%% %a')

      paths.each do |path|
        progressbar.log("Compiling: #{path}")
        replace_with_encoded(path, mode: mode)
        progressbar.increment
      end
    end

    def copy_dir(source, output)
      FileUtils.mkdir_p output
      FileUtils.cp_r File.join(source, '.'), output
    rescue StandardError => e
      raise Rien::CliHelper.make_failed_to_copy_error(source, e.message)
    end

    def move_dir(source, output)
      FileUtils.mv source.to_s, output
    rescue StandardError => e
      raise Rien::CliHelper.make_failed_to_move_error(source, e.message)
    end

    def pack_all_files_in_directory(source, output, tmpdir, mode: :plain)
      # Copy to temp workspace
      time_stamp = Time.now.strftime('%Y%m%d%H%M%S')
      temp_workspace = File.expand_path(time_stamp, tmpdir)
      copy_dir(source, temp_workspace)

      # Change to temp workspace
      msg = ''
      Dir.chdir(temp_workspace) do
        # Encode
        # pack all files
        files = Dir['./**/*.rb']
        pack_files(files, mode: mode)

        msg = <<~MSG
          Successed to compile and pack #{source} into #{output}
          total #{files.length} file(s)
        MSG
      end

      move_dir(temp_workspace, output)

      puts msg.green
    end

    def use_ruar_to_serialize(source, output)
      ruar_key = Rien.config.ruar_key
      ruar_iv = Rien.config.ruar_iv
      ruar_auth_data = Rien.config.ruar_auth_data

      warn 'Ruar: Empty key, generate a new one'.yellow if ruar_key.nil?
      warn 'Ruar: Empty initialization vector, generate a new one'.yellow if ruar_iv.nil?
      if ruar_auth_data.nil?
        warn 'Ruar: You must set ruar_auth_data, abort!'.red
        return
      end

      Ruar.cipher.setup(key: ruar_key, iv: ruar_iv, auth_data: ruar_auth_data)
      Ruar::Serialize.aead(source, output)
    end

    def use_rienfile_to_pack(source)
      # Eval Rienfile
      begin
        rienfile = File.expand_path('Rienfile', source)
        load rienfile
      rescue StandardError => e
        raise Rien::CliHelper.make_failed_to_load_rienfile_error(rienfile, e.message)
      end

      # Configure
      status.silent = Rien.config.silent
      output = Rien.config.output
      tmpdir = Rien.config.tmpdir
      ruar = Rien.config.ruar

      # Copy to temp workspace
      time_stamp = Time.now.strftime('%Y%m%d%H%M%S')
      temp_workspace = File.expand_path(time_stamp, tmpdir)
      copy_dir(source, temp_workspace)

      # Change to temp workspace
      msg = ''
      Dir.chdir(temp_workspace) do
        # Encode
        files = Rien.config.effective_paths
        if ruar
          pack_files(files, mode: :ruar)
        else
          pack_files(files, mode: :plain)
        end

        FileUtils.rm './Rienfile' # under tmpdir
        msg = <<~MSG
          Successed to compile and pack #{source} into #{output}
          using #{rienfile}
          total #{files.length} file(s)
        MSG
      end
      move_dir(temp_workspace, output)
      puts msg.green
      use_ruar_to_serialize(output, "#{output}.ruar") if ruar
    end
  end
end
