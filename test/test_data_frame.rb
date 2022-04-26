# frozen_string_literal: true

require 'test_helper'

class DataFrameTest < Test::Unit::TestCase
  sub_test_case 'Constructor' do
    test 'new empty DataFrame' do
      assert_equal [], RedAmber::DataFrame.new.table.columns
      assert_equal [], RedAmber::DataFrame.new([]).table.columns
      assert_equal [], RedAmber::DataFrame.new(nil).table.columns
    end

    hash = { x: [1, 2, 3] }
    df = RedAmber::DataFrame.new(hash)
    data('hash 1 colum', [hash, df], keep: true)

    hash = { x: [1, 2, 3], 'y' => %w[A B C] }
    df = RedAmber::DataFrame.new(hash)
    data('hash 2 colums', [hash, df], keep: true)

    test 'new from a Hash' do
      hash, df = data
      assert_equal Arrow::Table.new(hash), df.table
    end

    test 'new from a RedAmber::DataFrame' do
      _, df = data
      assert_equal df.table, RedAmber::DataFrame.new(df).table
    end

    test 'new from a Arrow::Table' do
      hash, = data
      table = Arrow::Table.new(hash)
      df = RedAmber::DataFrame.new(table)
      assert_equal table, df.table
    end

    test 'new from an Array' do
      # assert_equal
    end

    test 'new from a Rover::DataFrame' do
      # aeert_equal
    end

    test 'Select rows by invalid type' do
      int32_array = Arrow::Int32Array.new([1, 2])
      assert_raise(RedAmber::DataFrameTypeError) { RedAmber::DataFrame.new(int32_array) }
    end
  end

  sub_test_case 'Properties' do
    hash = { x: [1, 2, 3], y: %w[A B C] }
    data('hash data',
         [hash, RedAmber::DataFrame.new(hash), %i[uint8 string]],
         keep: true)
    data('empty data',
         [{}, RedAmber::DataFrame.new, []],
         keep: true)

    test 'n_rows' do
      hash, df, = data
      size = hash.empty? ? 0 : hash.values.first.size
      assert_equal size, df.n_rows
      assert_equal size, df.nrow
      assert_equal size, df.length
    end

    test 'n_columns' do
      hash, df, = data
      assert_equal hash.keys.size, df.n_columns
      assert_equal hash.keys.size, df.ncol
      assert_equal hash.keys.size, df.width
    end

    test 'empty?' do
      hash, df = data
      assert_equal hash.empty?, df.empty?
    end

    test 'shape' do
      hash, df, = data
      expected = hash.empty? ? [0, 0] : [hash.values.first.size, hash.keys.size]
      assert_equal expected, df.shape
    end

    test 'column_names' do
      hash, df, = data
      hash_sym = hash.each_with_object({}) do |kv, h|
        k, v = kv
        h[k.to_sym] = v
      end
      assert_equal hash_sym.keys, df.column_names
      assert_equal hash_sym.keys, df.keys
    end

    test 'types' do
      _, df, types = data
      assert_equal types, df.types
    end

    test 'types class' do
      _, df, types = data
      types = [Arrow::UInt8DataType, Arrow::StringDataType] if types == %i[uint8 string]
      assert_equal types, df.types(class_name: true)
    end
  end
end