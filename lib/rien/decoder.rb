# frozen_string_literal: true

module Rien
  class Decoder
    def self.check_version(version)
      version == RUBY_VERSION
    end

    def self.check_version!(version)
      return if check_version(version)

      puts "Ruby Using: #{RUBY_VERSION}, Version Compiled: #{version}"
      exit(1)
    end

    def self.eval(filename)
      file = File.read(filename)
      ir_bin = Zlib::Inflate.inflate(file)
      ir = RubyVM::InstructionSequence.load_from_binary(ir_bin)
      ir.eval
    end
  end
end
