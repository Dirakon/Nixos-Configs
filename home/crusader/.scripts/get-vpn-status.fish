#!/usr/bin/env fish

# TODO: actualize for xray/nekoray
# Expecting error code on no connection
nmcli device show wg0 >/dev/null 2>/dev/null

if [ $status = 0 ]
	echo '{"text": "on 󰓠"}'
else
	echo '{"text": "off 󰓠"}'
end
