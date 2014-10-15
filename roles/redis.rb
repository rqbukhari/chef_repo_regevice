name 'redis'
description 'Redis server for apps'
run_list 'recipe[build-essential]', 'recipe[redisio::install]'
default_attributes('redisio' => { 'version' => '2.8.7', 'name' => '-server'})