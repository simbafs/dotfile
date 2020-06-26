alias ls='ls -shC1 --color=auto'
alias tree='tree -Ch -I node_modules'
alias home='cd ~'
alias bin='cd ~/bin'
alias code='cd ~/git'
alias rm='rm -r'
alias cp='cp -r'
alias pwd=dirs
alias ..='cd ../'
alias lls='vi .'
alias debian='sh ~/debian/start-debian'
alias 'gitinfo'='git diff --name-only --diff-filter=U'
alias ptt='ssh -C bbsu@ptt.cc'
alias gp='git pull'
alias qemu-iso='sudo qemu-system-x86_64 -m 2048 -boot d -enable-kvm -net nic -net user -cdrom'
alias qemu-usb='sudo qemu-system-x86_64 -m 2048 -boot c -enable-kvm -net nic -net user -hda'
alias qemu-mx="sudo qemu-system-x86_64 -m 2048 -boot d -enable-kvm -net user -drive format=raw,file=/home/simba/iso/hhd/hhd.dd"
alias axel='axel -n 6 -a'
alias tt=gtypist
alias apt="sudo apt"
alias ck="ncftp 203.64.138.1"
alias mp3-dl="youtube-dl -x --audio-format mp3"
alias ftp="ncftp"
alias r="cmatrix -abu 1 "
alias tmuxa="tmux a -t"
alias soundechoon="pactl load-module module-loopback latency_msec=1"
alias soundechooff="pactl unload-module module-loopback"
alias tmux="cd; tmux"
alias vps="ssh -i ~/.ssh/id_rsa simba_fs@35.229.189.79"
alias ckcsc="project ckcsc ~/git/ckcsc"
alias joker="project new-joker ~/git/new-joker"
alias wscan="iwlist scan > /dev/null"
alias port='sudo netstat -antpl'
alias bbs='ssh -p 25 bbsu@bbs.ckcsc.net'
alias ckcsc='ssh -p 25 ckcsc'
alias b52u8='iconv -f BIG-5 -t UTF-8'
