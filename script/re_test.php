<?php
$redis = new Redis();
$redis->connect('172.20.0.3', 6379);
$redis->set('key', 'zhangsan'); //设置值
$res = $redis->get('key');
echo $res;
$id = $redis->incr('id');//自增
$redis->hmset($id,array('user'=>'zhangsan','email'=>'addd@ff.com'));
print_r($redis->hgetall('2'));
?>