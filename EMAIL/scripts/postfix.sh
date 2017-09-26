#!/bin/bash


echo -e "Digite o endereço ip da VM, Por exemplo 192.168.218.128"
read $MYNETHOST

test $MYNETHOST || echo "Endereço ip da vm não encontrado"

GITDIR=/srv/services
GITURL='https://github.com/fiap2trc/services'

install_packages () {
clear && echo "Reinstalando pacotes do Bind9 e do Postfix" && sleep 2
debconf-set-selections <<< "postfix postfix/mailname string mail.fiap.edu.br"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
apt update
apt remove --purge bind9 mysql-server-5.7 mysql-server
apt install bind9 postfix procmail bsd-mailx telnet
}

change_hostname () {
clear && echo "Substituindo Hostname da Máquina" && sleep 2
hostname mail.fiap.edu.br
echo "mail.fiap.edu.br" > /proc/sys/vm/hostname
}

configure_services () {
clear && echo "Copiando arquivos de DNS e do Postfix" && sleep 2
git clone --progress $GITURL $GITDIR
cp -av $GITDIR/scripts/DNS/db.fiap.edu.br /etc/bind/
cp -av $GITDIR/scripts/DNS/db.218.168.192 /etc/bind/
cp -av $GITDIR/scripts/DNS/named.conf.local /etc/bind/
cp -av $GITDIR/scripts/DNS/named.conf.options /etc/bind/
cp -av $GITDIR/scripts/EMAIL/main.cf /etc/postfix/main.cf
cp -av $GITDIR/scripts/EMAIL/mailname /etc/mailname
}

replace_strings () {
rpl NETHOST $MYNETHOST /etc/bind/db.fiap.edu.br
rpl NETHOST $MYNETHOST /etc/bind/db.218.168.192
rpl NETHOST $MYNETHOST /etc/postfix/main.cf
}

change_dns () {
clear && echo "Apontando o endereço 127.0.0.1 no arquivo resolv.conf" && sleep 2
echo "nameserver 127.0.0.1" >  /etc/resolv.conf
echo "search fiap.edu.br"   >  /etc/resolv.conf
echo "nameserver 127.0.0.1" >> /etc/resolvconf/resolv.conf.d/head
echo "search fiap.edu.br"   >> /etc/resolvconf/resolv.conf.d/head
}

restart_services () {
systemctl enable bind9
systemctl enable postfix
systemctl restart bind9
systemctl restart postfix
}

install_packages
change_hostname
configure_services
replace_strings
change_dns
restart_services
