require "minitest/autorun"
require 'hoe'
require "hoe/version"
require 'tempfile'

class TestHoe; end

class TestHoe::TestVersion < MiniTest::Unit::TestCase
  include Hoe::Version

  attr_accessor :version

  def setup
    @version = '1.1.1'
    @files = []
    @spec = Gem::Specification.new
    @spec.files = @files
    ENV.delete 'VERSION'
  end
  def spec() @spec end

  def test_increment_minor
    v = increment [0,1,nil]
    assert_equal '1.2.0', v
  end

  def test_increment_major
    v = increment [1,nil,nil]
    assert_equal '2.0.0', v
  end

  def test_increment_patch
    v = increment [0,0,1]
    assert_equal '1.1.2', v
  end

  def test_override_increment
    ENV['VERSION'] = '4.5.6'
    refute increment [1,2,3]
  end

  def test_update_version
    expected = ["def nothing() 'No version here' end\n",
                "class Blah\n  VERSION = '1.1.1'\nend\n"]

    with_mock_files *expected do
      update_version '3.2.1'

      assert_equal expected[0], File.read(@files[0])
      expected[1].gsub! '1.1.1', '3.2.1'
      assert_equal expected[1], File.read(@files[1])

      assert_equal '3.2.1', version
      assert_equal '3.2.1', spec.version.version
    end
  end

  def test_update_version_false
    refute update_version 'vers'
  end

  def with_mock_files no_vers, with_vers
    Tempfile.open('no_vers') do |f1|
      f1.write no_vers
      f1.rewind
      @files << f1.path
      Tempfile.open('with_vers') do |f2|
        f2.write with_vers
        f2.rewind
        @files << f2.path

        yield
      end
    end
  end

end
