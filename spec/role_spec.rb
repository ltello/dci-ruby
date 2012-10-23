require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Role' do

  context "When defining roles inside a Context subclass..." do
    before(:all) do
      class ExampleContext < Context
        role :rolename do
        end
        role :anotherrolename do
        end
      end
    end
    it("You can define as many as you want") {ExampleContext.roles.keys.size.should eql(2)}
    it("Each rolename must be provided as a symbol...") {ExampleContext.roles.keys.should include(:rolename)}
    it("...and not as a string") {expect {class ExampleContext < Context; role "rolename" do; end; end}.to raise_error}
    it("A block defining rolemethods can also be provided.") {ExampleContext.roles[:rolename].class.should be(Module)}
  end

end
