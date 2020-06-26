upload(){
	if [[ -L server ]];then
		sudo rm -rf server/*
		sudo cp -r * server/
		sudo rm server/server
	else
		echo "server doesn't exit"
	fi
}
