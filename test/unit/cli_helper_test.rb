require 'test_helper'

class CliHelperTest < Minitest::Test
  include Rien::CliHelper

  def setup
    FileUtils.cp_r 'test/samples/.', 'test/tmp'
  end

  def teardown
    FileUtils.remove_dir 'test/tmp'
  end

  def test_encode_single_plain
    source = 'test/tmp/plain.rb'

    binary = encode(source)

    refute(binary.nil?)
  end

  def test_reject_not_ruby_file
    source = 'test/tmp/not_ruby.rb'
    assert_raises(SystemExit){encode(source)}
  end

  def test_export_single_encoded_plain
    source = 'test/tmp/plain.rb'
    output = 'test/tmp/encoded_plain.rb'

    export_single_encoded(source, output)

    assert_path_exists(output)
  end

  def test_replace_with_encoded_plain
    source = 'test/tmp/plain.rb'
    encoded = 'test/tmp/plain.rb.rbc'

    replace_with_encoded(source)

    assert_path_exists(source)
    assert_path_exists(encoded)
  end

  def test_pack_all_files_in_directory
    source = 'test/tmp/dir'
    tmpdir = '/tmp/rien'
    output = 'test/tmp/packed'

    pack_all_files_in_directory(source, output, tmpdir)

    assert_path_exists('test/tmp/packed/ruby_in_dir.rb')
    assert_path_exists('test/tmp/packed/ruby_in_dir.rb.rbc')
  end

  def test_decode_single_plain
    source = 'test/tmp/plain.rb'
    expected = `ruby #{source}`

    replace_with_encoded(source)
    result = `ruby #{source}`

    assert_equal(expected, result)
  end

  def test_decode_require_relative_plain
    source = 'test/tmp/require_relative_plain.rb'
    expected = `ruby #{source}`

    replace_with_encoded(source)
    result = `ruby #{source}`

    assert_equal(expected, result)
  end

  def test_decode_read_eval_plain
    source = 'test/tmp/read_eval_plain.rb'
    expected = `ruby #{source}`

    replace_with_encoded(source)
    result = `ruby #{source}`

    assert_equal(expected, result)
  end

  def test_decode_load_plain
    source = 'test/tmp/load_plain.rb'
    expected = `ruby #{source}`

    replace_with_encoded(source)
    result = `ruby #{source}`

    assert_equal(expected, result)
  end

  def test_decode_require_gem
    source = 'test/tmp/require_gem.rb'
    expected = `ruby #{source}`

    replace_with_encoded(source)
    result = `ruby #{source}`

    assert_equal(expected, result)
  end

  def test_decode_autoload_gem
    source = 'test/tmp/autoload_gem.rb'
    expected = `ruby #{source}`

    replace_with_encoded(source)
    result = `ruby #{source}`

    assert_equal(expected, result)
  end

end