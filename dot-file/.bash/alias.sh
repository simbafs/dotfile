alias rm='rm -r'
alias cp='cp -r'
alias ls='ls -hlF --color=auto'
alias pwd=dirs
alias ..='cd ../'
alias qemu-iso='sudo qemu-system-x86_64 -m 2048 -boot d -enable-kvm -net nic -net user -cdrom'
alias qemu-usb='sudo qemu-system-x86_64 -m 2048 -boot c -enable-kvm -net nic -net user -hda'
alias qemu-mx="sudo qemu-system-x86_64 -m 2048 -boot d -enable-kvm -net user -drive format=raw,file=/home/simba/iso/hhd/hhd.dd"
alias apt="sudo apt"
alias mp3-dl="youtube-dl -x --audio-format mp3"
alias s="cmatrix -abu 1 "
alias soundechoon="pactl load-module module-loopback latency_msec=1"
alias soundechooff="pactl unload-module module-loopback"
alias bbs='ssh -p 25 bbsu@bbs.ckcsc.net'
alias ckcsc='ssh -p 25 ckcsc'
alias b52u8='iconv -f BIG-5 -t UTF-8'
alias du='du -sh'
alias tree="tree -alI 'node_modules|.git|.next|out'"
alias arp='arp -a'
alias vps='ssh simba-vps'
alias port='netstat -antpl'
alias screenoff='xset dpms force off'
alias r='ranger; clear'
alias screenRotate='xrandr --output eDP --rotate'
alias grep='grep --color=always'
alias grepFind='grep --exclude-dir=node_modules -nr . -e'
alias czinit='commitizen init cz-conventional-changelog --save-dev --save-exact'
alias arp='arp -nve'
alias gr='cd $(git rev-parse --show-toplevel)'
# alias k=kubectl
alias vi=nvim
alias vim=nvim
alias mkdir='mkdir -p'
alias t=tmux
alias ptt='ssh bbsu@ptt.cc; clear'
alias copy='xclip -sel clip'
alias free='free -h'
