#!/bin/sh
IPTABLES=/sbin/iptables
MODPROBE=/sbin/modprobe
INT_NET=192.168.X.X
IFACE0='ensXX'
IFACE1='ensXX'

### -0- Flush de todas as regras e mudanças de todas as chains para DROP
echo "[+] Flushing existing iptables rules..."
$IPTABLES -F
$IPTABLES -F -t nat
$IPTABLES -X
$IPTABLES -P INPUT DROP
$IPTABLES -P OUTPUT DROP
$IPTABLES -P FORWARD DROP

### -1- carregando modulos de contrac
$MODPROBE ip_conntrack
$MODPROBE iptable_nat
$MODPROBE ip_conntrack_ftp
$MODPROBE ip_nat_ftp

### -2- Regra para anti loockup de SSH
$IPTABLES -A INPUT -p tcp --dport 22 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --sport 22 -j ACCEPT

###### INPUT chain ######
echo "[+] Setting up INPUT chain..."

### -3- Regras para tracking de estado de conexões
$IPTABLES -A INPUT -m state --state INVALID -j LOG --log-prefix "DROP INVALID " --log-ip-options --log-tcp-options
$IPTABLES -A INPUT -m state --state INVALID -j DROP
$IPTABLES -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

### -4- anti-spoofing rules
$IPTABLES -A INPUT -i $IFACE1 ! -s $INT_NET -j LOG --log-prefix "SPOOFED PKT "
$IPTABLES -A INPUT -i $IFACE1 ! -s $INT_NET -j DROP

### -5- ACCEPT rules
$IPTABLES -A INPUT -i $IFACE1 -p tcp -s $INT_NET --dport 22 --syn -m state  --state NEW -j ACCEPT
$IPTABLES -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

### -6- default INPUT LOG rule
$IPTABLES -A INPUT ! -i lo -j LOG --log-prefix "DROP " --log-ip-options --log-tcp-options



###### OUTPUT chain ######

echo "[+] Setting up OUTPUT chain..."
### rastreio de regras
$IPTABLES -A OUTPUT -m state --state INVALID -j LOG --log-prefix "DROP  INVALID " --log-ip-options --log-tcp-options

$IPTABLES -A OUTPUT -m state --state INVALID -j DROP
$IPTABLES -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

### -7- Liberação de regras de saida
$IPTABLES -A OUTPUT -p tcp --dport 22 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 43 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 80 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 443 --syn -m state --state NEW -j ACCEPT
$IPTABLES -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT
$IPTABLES -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT

### Regra de LOG default para saida

$IPTABLES -A OUTPUT ! -o lo -j LOG --log-prefix "DROP " --log-ip-options --log-tcp-options

###### FORWARD chain ######
echo "[+] Setting up FORWARD chain..."
### rastreio de regras ###

$IPTABLES -A FORWARD -m state --state INVALID -j LOG --log-prefix "DROP INVALID " --log-ip-options --log-tcp-options 
$IPTABLES -A FORWARD -m state --state INVALID -j DROP
$IPTABLES -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

### anti-spoofing rules
$IPTABLES -A FORWARD -i eth1 ! -s $INT_NET -j LOG --log-prefix "SPOOFED PKT "
$IPTABLES -A FORWARD -i eth1 ! -s $INT_NET -j DROP

### -8- ACCEPT rules

$IPTABLES -A FORWARD -p tcp -i $IFACE1 -s $INT_NET --dport 22 --syn -m state  --state NEW -j ACCEPT
$IPTABLES -t filter -A FORWARD -p tcp -m multiport -s $INT_NET --dport 80,443 -j ACCEPT
$IPTABLES -t filter -A FORWARD -p tcp -m multiport --sport 80,443 -d $INT_NET -j ACCEPT
$IPTABLES -A FORWARD -p udp --dport 53 -m state --state NEW -j ACCEPT
$IPTABLES -A FORWARD -p udp --sport 53 -d $INT_NET -j ACCEPT
$IPTABLES -A FORWARD -p icmp --icmp-type echo-request -j ACCEPT



### default log rule
$IPTABLES -A FORWARD ! -i lo -j LOG --log-prefix "DROP " --log-ip-options --log-tcp-options

###### NAT rules ######
echo "[+] Setting up NAT rules..."
$IPTABLES -t nat -A PREROUTING -p tcp --dport 80 -i $IFACE0 -j DNAT --to 192.168.10.11:80
$IPTABLES -t nat -A PREROUTING -p tcp --dport 443 -i $IFACE0 -j DNAT --to 192.168.10.11:443
$IPTABLES -t nat -A PREROUTING -p tcp --dport 53 -i $IFACE0 -j DNAT --to 192.168.10.11:53

$IPTABLES -t filter -A FORWARD -p tcp -m multiport -s $INT_NET -d 0/0 --dport 80,443 -j ACCEPT
$IPTABLES -t filter -A FORWARD -p tcp -m multiport -s 0/0 --sport 80,443 -d $INT_NET -j ACCEPT



$IPTABLES -t nat -A POSTROUTING -s $INT_NET -d 0/0 -j MASQUERADE

###### forwarding ######
echo "[+] Enabling IP forwarding..."
echo 1 > /proc/sys/net/ipv4/ip_forward

