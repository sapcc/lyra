require 'rails_helper'
require 'keyed_mutex'
RSpec.describe "KeyedMutex" do

  let(:keyed_mutex) { KeyedMutex.new }
  let(:mutex_key1) { keyed_mutex.get 'key1' }
  let(:mutex_key2) { keyed_mutex.get 'key2' }

  it 'returns a mutex when given a key' do
    expect(mutex_key1).to be_an(Mutex)
    expect(mutex_key2).to be_an(Mutex)
  end

  it 'gives a different mutexes for different keys' do
    expect(mutex_key1).not_to be(mutex_key2)
  end

  it 'gives same mutex for the same key' do
    expect(mutex_key1).to be(keyed_mutex.get('key1'))
    expect(mutex_key2).to be(keyed_mutex.get('key2'))
  end
end
