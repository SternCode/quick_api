require 'test/unit'
require 'quick_api'

class FooBar 
  include QuickApi::Mongoid
  attr_accessor :name, :last_name, :token
  
  quick_api_attributes :token, :name
end

class TestQuickApi < Test::Unit::TestCase

  def test_attributes
    fb = FooBar.new(name: 'Stern', last_name: 'Code', token: '0112358132134')
    result = {token: '0112358132134', name: 'Stern'}
    assert_equal result, fb.to_api
  end

end
