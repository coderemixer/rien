# frozen_string_literal: true

require 'test_helper'

class EncoderTest < Minitest::Test
  def setup
    FileUtils.mkdir_p 'test/tmp'
    FileUtils.cp_r 'test/samples/.', 'test/tmp'
  end

  def teardown
    FileUtils.remove_dir 'test/tmp'
  end

  def encoder
    @encoder ||= Rien::Encoder.new
  end

  def test_encode_single_plain
    source = 'test/tmp/plain.rb'
    binary = encoder.encode_file(source)
    refute(binary.nil?)
  end

  def test_reject_not_ruby_file
    source = 'test/tmp/not_ruby.rb'
    assert_raises(Exception) { encoder.encode_file(source) }
  end
end
