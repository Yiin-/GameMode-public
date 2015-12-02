<?php
	shell_exec('git add gamemode.amx');
	shell_exec('git commit -m "'. date('Y-m-d H:i', strtotime('1 hour')) . '"');
	shell_exec('git push');