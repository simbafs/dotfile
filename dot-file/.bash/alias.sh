alias rm='rm -r'
alias cp='cp -r'
alias ls='ls -hlF --color=auto'
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
alias vps='ssh vps.simbafs.cc'
alias port='netstat -antpl'
alias screenoff='xset dpms force off'
alias screenRotate='xrandr --output eDP --rotate'
alias grep='grep --color=always'
alias grepFind='grep --exclude-dir=node_modules -nr . -e'
alias arp='arp -nve'
alias gr='cd $(git rev-parse --show-toplevel)'
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
