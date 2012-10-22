module Kernel
  def singleton_class
    class << self
      self
    end
  end unless respond_to?(:singleton_class)
end

