require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'ostruct'

describe 'RolePlayers' do

  context "Are Ruby objects inside a context instance" do
    before(:all) do
      class AnotherContext < Context
        role :role1 do
          def rolemethod1
            :rolemethod1_executed
          end
        end
        role :role2 do
          def rolemethod2
            role1
          end
        end

        def interaction1
          role1
        end

        def interaction2
          role1.object_id - role2.object_id
        end
      end
      @player1, @player2 = OpenStruct.new(:field1 => 'value1'), OpenStruct.new(:field2 => 'value2')
      @example_context   = AnotherContext.new(:role1 => @player1, :role2 => @player2)
    end

    it("that besides their normal behaviour...") do
      @player1.field1.should eql('value1')
    end
    it("...also respond to the rolemethods defined in their playing role.") do
      @example_context.role1.rolemethod1.should eql(:rolemethod1_executed)
    end
    it("Roleplayers can access other roleplayers in their context...") do
      @example_context.role2.rolemethod2.should eql(@example_context.role1)
    end
    it("...and even the context itself.") do
      @example_context.role2.context.should eql(@example_context)
    end
  end

end
