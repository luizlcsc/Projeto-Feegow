<?php
$command = "git symbolic-ref -q --short HEAD || git describe --tags --exact-match 2>&1";
exec($command, $output);
echo json_encode($output);