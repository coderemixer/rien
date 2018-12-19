class Rien::Decoder
  def self.check_version(version)
    version == RUBY_VERSION
  end

  def self.eval(filename)
    file = File.read(filename)
    ir_bin = Zlib::Inflate.inflate(file)
    ir = RubyVM::InstructionSequence.load_from_binary(ir_bin)
    ir.eval
  end
end
