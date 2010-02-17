<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>jnb-flash</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />
	
	<script src="js/swfobject.js" type="text/javascript"></script>
	<script type="text/javascript">
		var flashvars = {
		};
		var params = {
			menu: "false",
			scale: "noScale",
			allowFullscreen: "true",
			allowScriptAccess: "always",
			bgcolor: "#FFFFFF"
		};
		var attributes = {
			id:"jumpnbump"
		};
		swfobject.embedSWF("jumpnbump.swf", "altContent", "800", "512", "9.0.0", "expressInstall.swf", flashvars, params, attributes);
	</script>
	<style>
		a { color: #555; text-decoration: none; }
		a:hover { text-decoration: underline; }
	
		html, body 
		{
			background-color: #111;
			color: #444;
		}
		body 
		{ 
			font-family: sans-serif;
			text-align: center; 
			margin: 0 0 0 0; 
			vertical-align: middle 
		}
		#container 
		{ 
			width: 808px; 
			padding: 8px; 
			text-align: left; 
			margin: 0 auto; 
		}
		object { border:4px solid #333333; }
		h1 { padding: 13px 7px; margin: 32px 0 0 0; text-align: left; }
		p { font-size: 0.7em; margin: 0; padding: 16px 16px; text-align: right; }
	</style>
	
</head>
<body>
	<div id="container">
		<h1>jnb-flash</h1>
		<div id="altContent">
			<p><a href="http://www.adobe.com/go/getflashplayer"><img 
				src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" 
				alt="Get Adobe Flash player" /></a></p>
		</div>
		<p>
			<a href="http://github.com/maka/jnb-flash">GitHub / jnb-flash</a>. 
			Original DOS game by <a href="http://brainchilddesign.com/">Brainchild Design</a>. 
			A <a href="http://icculus.org/jumpnbump/">Win32 port</a> is available.
			<?php
			/*
			Last modified: xx ago script
			- http://korn19.ch/coding/last_modified.php
			- Contact: http://korn19.ch/misc/contact.php

			Do whatever you want with this code
			*/
			// get how many seconds ago the file got modified.
			$last_modified = time() - filemtime("jumpnbump.swf");

			if(round($last_modified/(24*60*60)) >= 1){ // has it been over a day?
				$last_modified /= (24*3600);
				if(round($last_modified/7) > 0){ // at least one week?
					$last_modified /= 7;
					if(round($last_modified/4) > 0){ // .. months?
						$last_modified /= 4;
						$output = '~'.round($last_modified).' months';
					}
					else{
						$output = round($last_modified).' weeks';
					}
				}
				else{
					$output = round($last_modified).' days';
				}
			}
			else if(round($last_modified/3600) >= 1){ // At least one hour ago
				$output = round($last_modified/3600).' hours';
			}
			else{
				if($last_modified/60 < 1){ // barely a few secs ago
					$output = $last_modified.' seconds';
				}
				else{
					$output = round($last_modified/60).' minutes';
				}
			}
			if(substr($output, 0, 2) == "1 "){
				$output = substr($output, 0, -1);
			}
			echo '<em>Last update was <strong>'.$output.' ago</strong>.</em>';
			?> 
		</p>
	</div>
</body>
</html>