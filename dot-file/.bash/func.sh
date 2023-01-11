# upload(){
#	if [[ -L server ]];then
#		sudo rm -rf server/*
#		sudo cp -r * server/
#		sudo rm server/server
#	else
#		echo "server doesn't exit"
#	fi
# }

# json(){
#     t="curl -s --header \"Content-Type: application/json\" --data '$2' \"$1\" | jq \".\""
#     bash -c $t
# }
#

sshTunnel(){
	if [[ $1 == 'kill' ]];then
		kill $(ps -ax | grep '[s]sh -NfR' | awk '{print $1}')
	else
		echo PORT $1
		ssh -NfR 9999:localhost:$1 simba-fs.dev
	fi
}

notmux(){
	touch ~/.notmux && 
	gnome-terminal & disown &&
	rm ~/.notmux
}
