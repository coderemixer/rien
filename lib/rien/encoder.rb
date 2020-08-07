class Rien::Encoder
  def initialize(version=RUBY_VERSION)
    @version = version
  end

  def encode_file(filepath)
    bytecode = RubyVM::InstructionSequence.compile_file(filepath, options: Rien::Const::COMPILE_OPTION)
    Zlib::Deflate.deflate(bytecode.to_binary)
  end

  def bootstrap
    <<-EOL
require 'rien'

Rien::Decoder.check_version!('#{RUBY_VERSION}')
Rien::Decoder.eval("\#{__FILE__}.rbc")
    EOL
  end

end
