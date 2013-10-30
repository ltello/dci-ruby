require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
# require 'ostruct'


describe 'Players:' do

  class CheckingAccount
    attr_reader   :account_id
    attr_accessor :balance

    def initialize(account_id, initial_balance=0)
      @account_id, @balance = account_id, initial_balance
    end
  end


  class MoneyTransferContext < DCI::Context

    # Roles Definitions
      role :source_account do
        delegate_to_player :balance
        private_delegate_to_player :balance=

        def run_transfer_of(amount)
          self.balance -= amount
        end
      end

      role :target_account do
        delegate_to_player :balance
        private_delegate_to_player :balance=
        # def_delegators :player, :balance, :balance=
        # private :balance=

        def run_transfer_of(amount)
          self.balance += amount
        end
      end

    # Interactions
      def run(amount=settings(:amount))
        source_account.run_transfer_of(amount)
        target_account.run_transfer_of(amount)
        balances
      end

    private
      def accounts
        [source_account, target_account]
      end

      def balances
        accounts.map(&:balance)
      end
  end

  context "Are common Ruby objects that play roles inside contexts:" do
    before(:all) do
      @account1 = CheckingAccount.new(1, 1000)
      @account2 = CheckingAccount.new(2)
      @account1_public_interface = @account1.public_methods
    end

    context "Before becoming roleplayers inside a context..." do
      it("...they are in an initial state...") do
        @account1.balance.should be(1000)
        @account2.balance.should be(0)
      end
      it("...and have got a given public interface.") do
        @account1_public_interface.should be_true
      end
    end

    context "After playing a role inside a context..." do
      before(:all) do
        MoneyTransferContext.new(:source_account => @account1,
                                 :target_account => @account2).run(200)
      end
      it("...they still preserve their public interface...") do
        @account1.public_methods.should eql(@account1_public_interface)
        @account1.should_not respond_to(:run_transfer_of)
        @account1.private_methods.should_not include(:run_transfer_of)
      end
      it("...although their state might have been changed!") do
        @account1.balance.should_not be(1000)
        @account2.balance.should_not be(0)
      end
    end
  end

end
