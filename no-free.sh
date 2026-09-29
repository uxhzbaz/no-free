M=${0%/*};C=/sdcard/Android/no-free;E=system/etc/hosts;H=/data/adb/metamodule/mnt/no-free/$E;[ -f $H ]||H=$M/$E
mkdir -p $C;cd $C||exit
[ -f config.txt ]||cp $M/config.txt .
c(){ dumpsys package $p|sed -n "/^$1 Resolver/,/^[A-Z]/p"|grep -o "$p/[^ ]* filter"|sed "s|\(.*\) filter|<$2 block='true'><component-filter name='\1'/></$2>|"|sort -u;}
L(){ sed -n "/^\[$1\]/,/^\[/{/^\[/d;s/#.*//;s/[[:space:]]//g;/./p}" config.txt;}
P(){ case $2 in */*)pm $1 $2;;*)for a in RUN_IN_BACKGROUND RUN_ANY_IN_BACKGROUND;do cmd appops set --user 0 $2 $a $3;done;x=/data/system/ifw/nf.$2.xml;rm -f $x;[ $3 = ignore ]&&{ { echo '<rules>';c Service service;c Receiver broadcast;echo '</rules>';}>$x;am force-stop $2;};esac;}
q(){ iptables "$@";ip6tables "$@";}
D(){ for p in $1;do echo "$2"|grep -qxF $p||P $3 $p $4;done;}
d(){ n=${1-$(L 禁用)};o=$(cat .s);D "$n" "$o" disable ignore;D "$o" "$n" enable default;echo "$n">.s;}
f(){ q -N nf;q -F nf;q -D OUTPUT -j nf;q -I OUTPUT -j nf
for p in $(L 断网);do set -- $(grep "^$p " /data/system/packages.list);[ $2 ]&&q -A nf -m owner --uid-owner $2 -j REJECT;done
for a in $(L IP);do q -A nf -d $a -j REJECT;done;}
h(){ X=$(sed '/^#NF$/,$d' $H;echo '#NF';L 域名|sed 's/^/0.0.0.0 /');echo "$X">$H;}
case $1 in u)d "";q -D OUTPUT -j nf;q -F nf;q -X nf;;c)cat config.txt;;*)d;f;h;esac
