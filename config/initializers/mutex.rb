require 'keyed_mutex'
$repository_semaphore = KeyedMutex.new
