# encoding: utf-8
# vim: set shiftwidth=2 tabstop=2 expandtab:

require 'minitest/unit'

# MiniTest::Unit::TestCase have no `name` property
module MiniTest
  class Unit
    class TestCase
      def name
        __name__
      end unless instance_methods.include?(:name)
    end
  end
end
