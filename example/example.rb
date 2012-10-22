require 'dci-ruby'


# We can think of a context as setting a scene.
class MoneyTransfer < Context
  role :source_account do
    def transfer(amount)
      decrease_balance(amount)
      puts "Tranfered $#{amount} from account ##{account_id}."
    end
  end

  role :destination_account do
    def transfer(amount)
      increase_balance(amount)
      puts "Tranfered $#{amount} into account ##{account_id}."
    end
  end

  def transfer(amount)
    puts "Begin transfer."
    [source_account, destination_account].each { |role| role.transfer(amount) }
    puts "Transfer complete."
  end
end

class Account
  def initialize(account_id)
    @account_id = account_id
    @balance    = 0
  end
  def account_id
    @account_id
  end
  def available_balance
    @balance
  end
  def increase_balance(amount)
    @balance += amount
  end
  def decrease_balance(amount)
    @balance -= amount
  end
end

acct1 = Account.new(000100)
acct2 = Account.new(000200)

MoneyTransfer.new(:source_account      => acct1,
                  :destination_account => acct2).transfer(50)
