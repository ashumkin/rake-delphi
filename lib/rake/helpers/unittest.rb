# encoding: utf-8

require 'test/unit'

# Ruby 1.9 uses "minitest". There is no `name` property there
if defined? MiniTest::Unit::TestCase && Test::Unit::TestCase < MiniTest::Unit::TestCase
    module Test
        module Unit
            class TestCase
                def name
                    __name__
                end unless instance_methods.include?(:name)
            end
        end
    end
end

