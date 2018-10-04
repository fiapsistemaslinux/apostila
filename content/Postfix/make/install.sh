#!/bin/bash

FILESPATH="$PWD/files"
FQDN=$(hostname -f)

installpackages () {
clear && echo "Reinstalando pacotes do Bind9 e do Postfix" && sleep 2
echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" > /etc/resolv.conf
debconf-set-selections <<< "postfix postfix/mailname string $FQDN"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
apt update
apt install bind9 postfix procmail bsd-mailx telnet rsync -y
}

configureservices () {
clear && echo "Sincronizando arquivos de DNS e do Postfix gerados via template" && sleep 2
rsync -av $FILESPATH/dns/ /etc/bind/
rsync -av $FILESPATH/postfix/ /etc/postfix/
sleep 1
}

configuredns () {
clear && echo "Apontando o endereço 127.0.0.1 no arquivo resolv.conf" && sleep 2
echo "nameserver 127.0.0.1" >  /etc/resolv.conf
echo "search fiap.edu.br"   >> /etc/resolv.conf
echo "nameserver 127.0.0.1" >> /etc/resolvconf/resolv.conf.d/head
echo "search fiap.edu.br"   >> /etc/resolvconf/resolv.conf.d/head
}


restartservices () {
systemctl enable bind9
systemctl enable postfix
systemctl restart bind9
systemctl restart postfix
}

validate () {
clear && echo "Testando a resolução de nomes para ponteiros de NS" && sleep 2
dig -t NS fiap.edu.br +short && sleep 2
clear && echo "Testando a resolução de nomes para ponteiros de IPV4" && sleep 2
dig mail.fiap.edu.br +short && sleep 2
clear && echo "Testando a resolução de nomes para ponteiros de MX" && sleep 2
dig -t MX fiap.edu.br +short && sleep 2
}

installpackages
configureservices
configuredns
restartservices
validate
