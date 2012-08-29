require 'test/unit'
require File.expand_path('../../lib/proto_j', __FILE__)

class Person < ProtoJ::Base
  field :name
  field :nicknames, :type => Array
  field :info,      :type => Hash
end

class MyTest < Test::Unit::TestCase
  def test_1
    honghao = Person.new

    assert_equal(nil, honghao.name)
    assert_equal(Array, honghao.nicknames.class)
    assert_equal(Hash, honghao.info.class)
  end

  def test_2
    honghao           = Person.new
    honghao.nicknames = ['agate', 'hh']
    honghao.info      = {'foo' => 'bar'}

    assert_equal(['agate', 'hh'],  honghao.nicknames)
    assert_equal({'foo' => 'bar'}, honghao.info)
  end

  def test_3
    honghao           = Person.new
    honghao.nicknames = '["agate","hh"]'
    honghao.info      = '{"foo":"bar"}'

    assert_equal(['agate', 'hh'],  honghao.nicknames)
    assert_equal({'foo' => 'bar'}, honghao.info)
  end

  def test_4
    honghao = Person.new

    honghao.name = 1
    assert_equal(1,  honghao.name)

    honghao.name = '1'
    assert_equal('1',  honghao.name)

    honghao.name = []
    assert_equal([],  honghao.name)

    honghao.name = {}
    assert_equal({},  honghao.name)
  end
end
