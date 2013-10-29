require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Role' do

  context "When defining roles inside a DCI::Context subclass..." do
    before(:all) do
      class TestingRoleContext < DCI::Context
        role :rolename do
        end
        role :anotherrolename do
        end
      end
    end
    it("...you can define as many as you want.") do
      TestingRoleContext.roles.keys.size.should eql(2)
    end
    it("Each rolename must be provided as a symbol...") do
      TestingRoleContext.roles.keys.should include(:rolename, :anotherrolename)
    end
    it("...and not as a string.") do
      expect do
        class TestingRoleContext < DCI::Context
          role "rolename" do
          end
        end
      end.to raise_error
    end
    it("A block defining rolemethods must be provided as well.") do
      TestingRoleContext.roles[:rolename].should be_a(Class)
    end
  end

end
