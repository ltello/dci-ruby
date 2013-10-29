require 'forwardable'
require 'dci-ruby'


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
      extend ::Forwardable
      def_delegators :player, :account_id, :balance, :balance=

      def run_transfer_of(amount)
        self.balance -= amount
        puts "\tAccount(\##{account_id}) sent #{amount}€ to Account(\##{target_account.account_id})."
      end
    end

    role :target_account do
      #[:account_id, :balance, :balance=].each {|field| define_method(field) {|*args| player.send(field, *args)}}
      def account_id;      player.account_id       end
      def balance;         player.balance          end
      def balance=(amount) player.balance=(amount) end
      private :balance=

      def run_transfer_of(amount)
        self.balance += amount
        puts "\tAccount(\##{account_id}) received #{amount}€ from Account(\##{source_account.account_id})."
      end
    end


  # Interactions

    def run(amount=settings(:amount))
      puts "Balances Before: #{balances}"
      source_account.run_transfer_of(amount)
      target_account.run_transfer_of(amount)
      puts "Balances After:  #{balances}"
    end


  private

    def accounts
      [source_account, target_account]
    end

    def balances
      accounts.map {|account| "#{account.balance}€"}.join(' - ')
    end
end

acc1 = CheckingAccount.new(1, 1000)
acc2 = CheckingAccount.new(2)

MoneyTransferContext.new(:source_account => acc1,
                         :target_account => acc2,
                         :amount         => 200).run
4.times do
  MoneyTransferContext.new(:source_account => acc1,
                           :target_account => acc2).run(200)
end
