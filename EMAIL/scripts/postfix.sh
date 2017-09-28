#!/bin/bash

clear
echo -e "Digite o endereço ip da VM, Por exemplo 192.168.218.128"
read MYNETHOST

test $MYNETHOST || echo "Endereço ip da vm não encontrado"

clear
echo -e "Qual a mascara de sub-rede? ( Valores suportados: /24 /16 ou /8 )"

read MYNETMASK
case $MYNETMASK in
 	/24)
		export NETMASK="/24"
		export MYREVERSE=$(echo $MYNETHOST | awk -F'.' '{ ptr=$3"."$2"."$1; print ptr }')
	   	export MYREVERSEFILE=$(echo $MYNETHOST | awk -F'.' '{ ptrfile="db."$3"."$2"."$1; print ptrfile }')
		export MYREVERSEPTR=$(echo $MYNETHOST | awk -F'.' '{ print $4 }')
	   	;;
 	/16)
		export NETMASK="/16"
		export MYREVERSE=$(echo $MYNETHOST | awk -F'.' '{ ptr=$2"."$1; print ptr }')
	   	export MYREVERSEFILE=$(echo $MYNETHOST | awk -F'.' '{ ptrfile="db."$2"."$1; print ptrfile }')
		export MYREVERSEPTR=$(echo $MYNETHOST | awk -F'.' '{ rev=$4"."$3; print rev }')
	   	;;
 	/8)
	 	export NETMASK="/8"
		export MYREVERSE=$(echo $MYNETHOST | awk -F'.' '{ print $1 }')
	   	export MYREVERSEFILE=$(echo $MYNETHOST | awk -F'.' '{ ptrfile="db."$1; print ptrfile }')
		export MYREVERSEPTR=$(echo $MYNETHOST | awk -F'.' '{ rev=$4"."$3"."$2; print rev }')
	   	;;
	*)
	   echo "Erro de configuração o script só suporta os valores /24 /16 ou /8" && sleep 2 && exit
esac


MYGATEWAY=$(ip r | grep default | awk -F' ' '{ print $3 }')
MYSERIAL=$(date +%Y%m%d01)

GITDIR=/srv/services
GITURL='https://github.com/fiap2trc/services'

## Funcs

install_packages () {
clear && echo "Reinstalando pacotes do Bind9 e do Postfix" && sleep 2
echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" > /etc/resolv.conf
debconf-set-selections <<< "postfix postfix/mailname string mail.fiap.edu.br"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
apt update
apt remove --purge bind9 mysql-server-5.7 mysql-server -y
apt install bind9 postfix procmail bsd-mailx telnet rpl -y
}

change_hostname () {
clear && echo "Substituindo Hostname da Máquina" && sleep 2
hostname mail.fiap.edu.br
echo "mail.fiap.edu.br" > /proc/sys/vm/hostname
}

configure_services () {
clear && echo "Copiando arquivos de DNS e do Postfix" && sleep 2
git clone --progress $GITURL $GITDIR
cp -av $GITDIR/EMAIL/scripts/files/db.fiap.edu.br /etc/bind/
cp -av $GITDIR/EMAIL/scripts/files/db.0.168.192 /etc/bind/$MYREVERSEFILE
cp -av $GITDIR/EMAIL/scripts/files/named.conf.local /etc/bind/
cp -av $GITDIR/EMAIL/scripts/files/named.conf.options /etc/bind/
cp -av $GITDIR/EMAIL/scripts/files/main.cf /etc/postfix/main.cf
cp -av $GITDIR/EMAIL/scripts/files/mailname /etc/mailname
sleep 1
}

replace_strings () {
rpl %NETHOST% $MYNETHOST /etc/bind/db.fiap.edu.br
rpl %SERIAL% $MYSERIAL /etc/bind/db.fiap.edu.br
rpl %DEFAULTGW% $MYGATEWAY /etc/bind/db.fiap.edu.br
rpl %NETHOST% $MYNETHOST /etc/bind/$MYREVERSEFILE
rpl %DNSREV% $MYREVERSEPTR /etc/bind/$MYREVERSEFILE
rpl %SERIAL% $MYSERIAL /etc/bind/$MYREVERSEFILE
rpl %NETHOST% $MYNETHOST /etc/postfix/main.cf
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
