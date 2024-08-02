#!/bin/bash
# alias rm='rm -r'
alias cp='cp -r'

if which lsd >/dev/null; then
	alias ls='lsd --date="+%Y/%m/%d %H:%M:%S" -l --size=short'
else
	alias ls='ls -hlF --color=auto'
fi

alias pwd=dirs
alias ..='cd ../'
alias qemu-iso='sudo qemu-system-x86_64 -m 2048 -boot d -enable-kvm -net nic -net user -cdrom'
alias qemu-usb='sudo qemu-system-x86_64 -m 2048 -boot c -enable-kvm -net nic -net user -hda'
alias qemu-mx="sudo qemu-system-x86_64 -m 2048 -boot d -enable-kvm -net user -drive format=raw,file=/home/simba/iso/hhd/hhd.dd"
alias apt="sudo apt"
alias s="cmatrix -abu 1 "
alias soundechoon="pactl load-module module-loopback latency_msec=1"
alias soundechooff="pactl unload-module module-loopback"
alias b52u8='iconv -f BIG-5 -t UTF-8'
alias du='du -sh'
alias tree="tree -alI 'node_modules|.git|.next|out'"
alias arp='arp -a'
alias screenoff='xset dpms force off'
alias screenRotate='xrandr --output eDP --rotate'
alias grep='grep --color=always'
alias grepFind='grep --exclude-dir=node_modules --exclude-dir=.next -nr . -e'
alias arp='arp -nve'
alias vi=nvim
alias vim=nvim
alias mkdir='mkdir -p'
alias ptt='ssh bbsu@ptt.cc&&clear'
alias copy='xclip -sel clip'
alias free='free -h'
alias fixBT='sudo rmmod btusb; sudo modprobe btusb'
alias python=python3
alias pw='pw | copy'
alias npm='pnpm'
alias npx='npm dlx'
alias less='less -R'
alias vnstat='vnstat wlo1'
alias gpg=gpg2
alias backup="rsync --archive --rsh ssh --delete --ignore-existing --info=progress2 --exclude='cache/' --exclude='Cache/' --exclude='.cache/' /home/simba/ simbafs@nas.simbafs.cc::home/nbBackup"
alias LINE='google-chrome --app=chrome-extension://ophjlpahpchlmihnnnihgmmeilfjmjjc/index.html'
alias nasfs='sshfs nas.simbafs.cc: nas/ -o uid=1000 -o gid=1000'
alias opt="curl -X POST -s  -H 'Cookie: OAKS_SESS1=kj3ffpki4ic5sa2drj1usv0pt6' 'https://iservice.nchc.org.tw/nchc_service/nchc_service_member_action.php?action=get_motp_count' | jq '.code' --raw-output"
alias fixAudio='echo 0 | sudo tee /sys/module/snd_hda_intel/parameters/power_save'
