M=${0%/*};C=/sdcard/Android/no-free;E=system/etc/hosts;H=/data/adb/metamodule/mnt/no-free/$E;[ -f $H ]||H=$M/$E
N='
'
mkdir -p $C;cd $C||exit
L(){ sed -n "/^\[$1\]/,/^\[/{/^\[/d;s/#.*//;s/[[:space:]]//g;/./p}" ${2-config.txt};}
w(){ a=0;while IFS= read -r l||[ "$l" ];do
case $l in \[*)[ $a = 1 ]&&[ "$2" ]&&echo "$2";a=0;[ "${l%%]*}" = "[$1" ]&&a=1;;
*)[ $a = 1 ]&&{ T=${l%%#*};case $T in *[![:space:]]*)continue;;esac;};;esac
echo "$l";done<config.txt;[ $a = 1 ]&&[ "$2" ]&&echo "$2";return 0;}
Z(){ w "$@">.t&&[ -s .t ]&&cat .t>config.txt||{ rm -f .t;exit 1;};rm -f .t;case $1 in 禁用)d;;域名)h;;*)f;;esac;}
c(){ echo "$y"|sed -n "/^$1 Resolver/,/^[A-Z]/p"|grep -o "$p/[^ ]* filter"|sed "s|\(.*\) filter|<$2 block='true'><component-filter name='\1'/></$2>|"|sort -u;}
P(){ p=$2;case $p in */*)pm $1 $p;;*)for a in RUN_IN_BACKGROUND RUN_ANY_IN_BACKGROUND;do cmd appops set --user 0 $p $a $3 &done;wait;x=/data/system/ifw/nf.$p.xml;rm -f $x;[ $3 = ignore ]&&{ y=$(dumpsys package $p);{ echo '<rules>';c Service service;c Receiver broadcast;echo '</rules>';}>$x;am force-stop $p;};esac;}
D(){ for p in $1;do case $N$2$N in *$N$p$N*);;*)P $3 $p $4;;esac;done;}
d(){ n=${1-$(L 禁用)};o=$(cat .s 2>/dev/null);D "$n" "$o" disable ignore;D "$o" "$n" enable default;echo "$n">.s;}
I(){ command -v $1>/dev/null||return;r=$(cat);{ echo '*filter';echo ':nf - [0:0]';echo ':nfs - [0:0]';echo "$r";echo COMMIT;}|$1-restore -n $W 2>/dev/null||echo "$r"|{ $1 $W -N nf;$1 $W -N nfs;$1 $W -F nf;$1 $W -F nfs;while read l;do [ "$l" ]&&$1 $W $l;done;} 2>/dev/null
$1 $W -C OUTPUT -j nf 2>/dev/null||$1 $W -I OUTPUT -j nf;}
f(){ iptables -w 5 -S OUTPUT>/dev/null 2>&1&&W='-w 5'||W=
B=$(L 断网);i=$(L IP);A=$(L 放行);s=$(L SNI);J=$(L 共享IP)
X=$(while read p u _;do case $u in 0|1000)continue;;esac
case $N$B$N in *$N$p$N*)echo "-A nf -m owner --uid-owner $u -j REJECT";;esac
case $N$A$N in *$N$p$N*)echo "-A nfs -m owner --uid-owner $u -j RETURN";;esac
done</data/system/packages.list)
i=$(echo "$i"|sort -u);R='s/.*/-A nf -d & -j REJECT/';Y=;G=
[ "$s" ]&&{ Y=$(echo "$s"|sed 's/.*/-A nfs -p tcp -m string --algo bm --from 5 --to 512 --string & -j REJECT --reject-with tcp-reset/');G='-A nf -p tcp --dport 443 -j nfs';[ "$J" ]&&G=$(echo "$J"|grep -E '^[0-9.]+(/[0-9]+)?$'|sed 's/.*/-A nf -p tcp --dport 443 -d & -j nfs/');}
{ echo '-A nf -o lo -j RETURN';echo "$X";echo "$Y";echo "$G";echo "$i"|grep -E '^[0-9]+(\.[0-9]+){3}(/[0-9]+)?$'|sed "$R";}|I iptables
{ echo '-A nf -o lo -j RETURN';echo "$X";[ "$J" ]||{ echo "$Y";echo "$G";};echo "$i"|grep -E '^[0-9a-fA-F]*:[0-9a-fA-F:.]*(/[0-9]+)?$'|sed "$R";}|I ip6tables;}
h(){ X=$(sed '/^#NF$/,$d' $H)||return;{ echo "$X";echo '#NF';L 域名|sed 's/^/0.0.0.0 /';}>$H;}
u(){ d "";for t in iptables ip6tables;do $t -D OUTPUT -j nf;$t -F nf;$t -F nfs;$t -X nf;$t -X nfs;done 2>/dev/null;}
[ -f config.txt ]||cp $M/config.txt .
grep -q '^\[放行\]' config.txt||for k in SNI 共享IP 放行;do grep -q "^\[$k\]" config.txt||printf '\n[%s]\n' $k>>config.txt;done
case $1 in u)u;;c)cat config.txt;;t)n=$(L $2|grep -vxF "$3");[ "$4" = 1 ]&&n=${n:+$n$N}$3;Z $2 "$n";;w)Z $2 "$(echo $3|base64 -d)";;*)f;h;d;esac;exit 0
