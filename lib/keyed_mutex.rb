class KeyedMutex

  def initialize
    @mu = Mutex.new
    @mutexes = Hash.new { |hsh, key| hsh[key] = Mutex.new }
  end

  def get(key)
    @mu.synchronize do
      return @mutexes[key]
    end
  end

end
