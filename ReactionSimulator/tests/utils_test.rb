require 'test/unit'
require 'ruby_extensions'

class UtilsTest < Test::Unit::TestCase
    
    def test_hash
        assert_equal ({:a => 14, :b => 22}), {:a => 7, :b => 11}.map_values { |val| val * 2 }
    end
    
end
