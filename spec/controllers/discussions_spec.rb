require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Discussions Controller", "index action" do
  before(:each) do
    @controller = Discussions.build(fake_request)
    @controller.dispatch('index')
  end
end