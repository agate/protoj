require 'test/unit'
require File.expand_path('../../lib/proto_j', __FILE__)

class IdCard < ProtoJ::Base
  field :id
end

class Computer < ProtoJ::Base
  field :cpu
  field :mem
  field :hd
end

class Person < ProtoJ::Base
  field :name
  field :age
  field :sex
  field :others

  has_one :id_card, :class => IdCard
  has_many :computers, :class => Computer
end

class MyTest < Test::Unit::TestCase
  def test_1
    empty_json = '{"name":null,"age":null,"sex":null,"others":null,"id_card":{"id":null},"computers":[]}'
    honghao = Person.new
    assert_not_nil(honghao.id_card)
    assert_equal([], honghao.computers)
    assert_equal(ProtoJ::Utils.to_sorted_json(empty_json), honghao.to_json)
  end

  def test_2
    json = '{"name":"honghao","age":26,"sex":"male","id_card":{"id":123456},"computers":[{"cpu":"i7","mem":"8G","hd":"500G"},{"cpu":"Q6600","mem":"8G"}]}'
    honghao = Person.new(json)

    assert_equal('honghao', honghao.name)
    assert_equal(26, honghao.age)
    assert_equal('male', honghao.sex)

    assert_equal(IdCard, honghao.id_card.class)
    assert_equal(123456, honghao.id_card.id)

    assert_equal(2, honghao.computers.size)
    assert_equal(Computer, honghao.computers.first.class)
    assert_equal('500G', honghao.computers.first.hd)
    assert_equal(nil, honghao.computers.last.hd)

    hash = JSON.parse(json)
    hash['computers'].last['hd'] = nil
    hash['others'] = nil
    assert_equal(ProtoJ::Utils.to_sorted_hash(hash).to_json, honghao.to_json)

    honghao.others = { :foo => 1, :bar => 2 }
    hash['others'] = { :foo => 1, :bar => 2 }
    assert_equal(ProtoJ::Utils.to_sorted_hash(hash).to_json, honghao.to_json)
  end

  def test_3
    json = '{"name":"honghao","age":26,"sex":"male","id_card":{"id":123456},"computers":[{"cpu":"i7","mem":"8G","hd":"500G"},{"cpu":"Q6600","mem":"8G"}]}'

    honghao = Person.new(json)

    # fields
    honghao.update('{"age":27}')
    assert_equal('honghao', honghao.name, 'no changes')
    assert_equal(27, honghao.age)

    # has_one
    honghao.update('{"id_card":{}}')
    assert_equal(123456, honghao.id_card.id, 'no changes')
    honghao.update('{"id_card":{"id":345678}}')
    assert_equal(345678, honghao.id_card.id)

    # has_many
    assert_raise JSON::ParserError do
      honghao.update('{"computers":"asdf"}')
    end
    honghao.update('{"computers":"{}"}')
    assert_equal(2, honghao.computers.size, 'no changes if computers is not array')
    honghao.update('{"computers":"[]"}')
    assert_equal(0, honghao.computers.size)
    honghao.update('{"computers":[{"cpu":"i7","mem":"8G","hd":"500G"}]}')
    assert_equal(1, honghao.computers.size)
    assert_equal('i7', honghao.computers.first.cpu)
  end
end
