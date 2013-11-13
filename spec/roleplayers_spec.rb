require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'ostruct'

describe 'RolePlayers' do

  context "Are Ruby objects inside a context instance..." do
    before(:all) do
      class TestingRoleplayersContext < DCI::Context
        role :role1 do
          def rolemethod1
            :rolemethod1_executed
          end
        end

        role :role2 do
          def rolemethod2
            role1
          end

          private

          def private_rolemethod2
            :public_rolemethod_return_value
          end
        end

        def interaction1
          role1
        end

        def interaction2
          role1.object_id - role2.object_id
        end
      end
      @player1, @player2 = OpenStruct.new(:name => 'player1'), OpenStruct.new(:name => 'player2')
      @testing_roleplayers_context = TestingRoleplayersContext.new(:role1    => @player1,
                                                                   :role2    => @player2,
                                                                   :setting1 => :one,
                                                                   :setting2 => :two,
                                                                   :setting3 => :three)
    end

    it("...each one instance of the class defined after the role he plays...") do
      @testing_roleplayers_context.send(:role1).should be_a(TestingRoleplayersContext::Role1)
      @testing_roleplayers_context.send(:role2).should be_a(TestingRoleplayersContext::Role2)
    end
    it("...so they adquire the public instance methods defined in their role...") do
      @testing_roleplayers_context.send(:role1).public_methods(false).should include('rolemethod1')
      @testing_roleplayers_context.send(:role1).should respond_to(:rolemethod1)
      @testing_roleplayers_context.send(:role1).rolemethod1.should eql(:rolemethod1_executed)
    end
    it("...as well as the private ones.") do
      @testing_roleplayers_context.send(:role2).private_methods(false).should include('private_rolemethod2')
      @testing_roleplayers_context.send(:role2).should_not respond_to(:private_rolemethod2)
      @testing_roleplayers_context.send(:role2).send(:private_rolemethod2).should eql(:public_rolemethod_return_value)
    end

    it("Also, through the private method #player") do
      @testing_roleplayers_context.send(:role1).private_methods.should include('player')
    end
    it("...they have access to the original object playing the role...") do
      @testing_roleplayers_context.send(:role1).send(:player).should be(@player1)
      @testing_roleplayers_context.send(:role2).send(:player).should be(@player2)
    end
    it("...and, therefore, its public interface.") do
      @testing_roleplayers_context.send(:role1).send(:player).name.should eq('player1')
      @testing_roleplayers_context.send(:role2).send(:player).name.should eq('player2')
    end

    it("Roleplayers have private access to other roleplayers in their context through methods named after their keys.") do
      @testing_roleplayers_context.send(:role2).private_methods.should include('role1')
      @testing_roleplayers_context.send(:role2).rolemethod2.should be(@testing_roleplayers_context.send(:role1))
    end
    it("However, they dont have a method to access the context.") do
      expect {@testing_roleplayers_context.send(:role2).send(:context)}.to raise_error(NoMethodError)
      @testing_roleplayers_context.send(:role2).instance_variables.should include('@context')
      @testing_roleplayers_context.send(:role2).instance_variable_get(:@context).should be(@testing_roleplayers_context)
    end

    it("They also have private access to extra args received in the instantiation of its context...") do
      @testing_roleplayers_context.private_methods.should include('settings')
    end
    it("...calling #settings that returns a hash with all the extra args...") do
      @testing_roleplayers_context.send(:settings).should eq({:setting1 => :one, :setting2 => :two, :setting3 => :three})
    end
    it("...or #settings(key) that returns the value of the given extra arg...") do
      @testing_roleplayers_context.send(:settings, :setting2).should be(:two)
    end
    it("...or #settings(key1, key2, ...) that returns a hash with the given extra args.") do
      @testing_roleplayers_context.send(:settings, :setting1, :setting3).should eq({:setting1 => :one, :setting3 => :three})
    end

  end

end
