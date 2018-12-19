require_relative 'lib/rien'

encoder = Rien::Encoder.new
bytes = encoder.encode("puts 'Hello World'")

puts bytes
puts encoder.generate('wat')

puts __FILE__
