<?php
error_reporting(E_ALL); ini_set('display_errors', 1); 


function get_server_memory_usage(){
	
	$free = shell_exec('free');
	$free = (string)trim($free);
	$free_arr = explode("\n", $free);
	$mem = explode(" ", $free_arr[1]);
	$mem = array_filter($mem);
	$mem = array_merge($mem);
	$memory_usage = $mem[2]/$mem[1]*100;

	return $memory_usage;
}

function get_server_cpu_usage(){

	$load = sys_getloadavg();
	return $load[0];

}

?>
<p><span class="description">Server Memory Usage:</span> <span class="result"><?php echo get_server_memory_usage(); ?></span></p>
<p><span class="description">Server CPU Usage: </span> <span class="result"><?php echo get_server_cpu_usage(); ?></span></p>
