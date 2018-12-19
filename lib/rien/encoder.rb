class Rien::Encoder
  def initialize(version=RUBY_VERSION)
    @version = version
  end

  def encode(str)
    bytecode = RubyVM::InstructionSequence.compile(str, options: Rien::Const::COMPILE_OPTION)
    Zlib::Deflate.deflate(bytecode.to_binary)
  end

  def bootstrap(path)
    <<-EOL
require 'rien'

Rien::Decoder.check_version('#{RUBY_VERSION}')
Rien::Decoder.eval('#{path}.rien')
    EOL
  end

  def encode_file(filepath)
    src = File.read(filepath)
    self.encode(src)
  end
end
