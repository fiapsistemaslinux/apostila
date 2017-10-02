##### Fiap - Soluções em Redes para ambientes Linux
profhelder.pereira@fiap.com.br

---
# iptables

## Base para construção de um firewall iptables

> O cookbook abaixo apresenta o passo a passo necessário para construirmos nosso firewall utilizando "apenas" iptables e outros recursos nativos do próprio sistema operacional como systemd e script shell, soluções como PFSense são extremamente úteis pela facilidade, quantidade de recursos e suporte da própria comunidade, mas a idéia aqui é sujar as mãos com o objetivo de evoluir nossa bagagem sobre o assunto.

O cookbook foi criado com base neste Layout de Redes emulado no Virtual Box, Você pode fazer o download das OVAS utilizadas no projeto a partir deste [link](https://mega.nz/#F!PUBiTQLL!u8usq56qO1RwEx5tt546Tg)

### Habilitando roteamento no Kernel Linux

Em sistemas GNU/Linux chamamos de **ip_forward** a configuração de kernel referente ao encaminhamento de pacotes entre interfaces, esse tipo de recurso é desabilitado por padrão devendo ser modificado manualmente caso necessário, ou seja, em casos onde o sistema operacional deverá trabalhar como roteador de pacotes entre redes.


1- Para ativarmos esse recurso altere a configuração do kernel para o arquivo **/proc/sys/net/ipv4/ip_forward:**
```sh
cat /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv4/ip_forward
```

2- Esse modelo de alteração é provisória pois ao próximo reboot o kernel deverá reestabelecer a configuração padrão da compilação, para alterar isso em definitivo o arquivo **/etc/sysctl.conf** deverá ser editado. 
```sh
# cat /etc/sysctl.conf
```

3- Dentro do arquivo de configuração verifique se a regra abaixo existe e está descomentada, do contrário crie a regra e execute o comando que segue:

```sh
# vim /etc/sysctl.conf
# net.ipv4.ip_forward=1
```

Após a alteração o comando **"sysctl -p"** fará a releitura deste arquivo, de forma que não seja necessário um rteboot para aplicar a alteração.

```sh
# sysctl -p
```

### Desabilitando o firewallD

FirewallD é uma solução de gerenciamento de firewall dinâmico implementado nas versões mais recentes dos projetos da Familia RedHat, sua proposta de divisão por zonas e sua sintaxe são estremamente interessantes mas não serão utilizados neste inicio de testes.

Dessa forma desative o firewallD e em seguida desabilite o serviço:

```sh
# systemctl stop firewalld
# systemctl disable firewalld
```

### Alterando a policy do firewall:

Analise o trafego de rede e verifique como funciona o ssh para liberarmos conexões antes de alterarmos a policy:

```sh
# tcpdump -n -i enp0s9 host 192.168.56.1 and port 22
```

Sabendo quais as portas a serem utilizadas, libere o trafego com destino a porta 22 do firewall:
```sh
# iptables -t filter -A INPUT -s 192.168.56.1 -p tcp --dport 22 -j ACCEPT
# iptables -t filter -A INPUT -s 192.168.1.0/24 -p tcp --dport 22 -j ACCEPT
# iptables -t filter -A OUTPUT -p tcp --sport 22 -d 0/0 -j ACCEPT
```

> A configuração acima deverá garantir os acessos via putty ( ssh ) mesmo após mudarmos as policys do firewall, Se for necessário uma restrição maior poderiamos ter configurado essa regra apenas para a interface enp0s3 conforme exemplo abaixo:
>  # iptables -t filter -A INPUT -p tcp -d 192.168.56.1 --dport 22 -i enp0s9 -j ACCEPT

Altere a policy do firewall para garantir o DROP de pacotes em todas as CHAINS da tabela filter:

```sh
# iptables -t filter -P INPUT DROP
# iptables -t filter -P OUTPUT DROP
# iptables -t filter -P FORWARD DROP
```

### Criando regras de configuração de DNS: 

Primeiro verifique no DNS se algum servidor externo foi apontado, no arquivo /etc/resolv.conf, motivo: Ainda não temos um DNS configurado em nossa rede 192.168.1.X

Feito isso crie as regras conforme abaixo para outgoing de DNS:
```sh
# iptables -t filter -A INPUT -p udp --sport 53 -d 0/0 -j ACCEPT
# iptables -t filter -A OUTPUT -p udp -s 0/0 --dport 53 -j ACCEPT
```

E se fosse necessário liberar apenas com base na interface enp0s3 ?
```sh
# iptables -t filter -A INPUT -p udp --sport 53 -d 0/0 -i enp0s3 -j ACCEPT
```

### Regras de configuração de acesso a porta 80 e 443:

É possível criar regras que se apliquem a mais de uma porta sem que seja necessário executar dois comandos diferentes no iptables, para esta finalidade utilizamos o parâmetro "-m":

```sh
# iptables -t filter -A OUTPUT -p tcp -m multiport -d 0/0 --dport 80,443 -j ACCEPT
# iptables -t filter -A INPUT -p tcp -m multiport -s 0/0 --sport 80,443 -i enp0s3 -j ACCEPT
```

> O parametro **-m** ou **--match** é utilizado para criar um condição de aplicação para a regra a partir de um módulo do iptables como connect, state ou multiport, ou seja a regra passa a depender, neste caso a condição utiliza o módulo multiport, para habilitar especificação de mais de uma porta na mesma regra, neste exemplos as portas 80 e 443.

Faça um teste executando novamente o yum update:

```sh
# yum update
```

### Liberando icmp com base no icmp-type do pacote:

O conjunto de regras abaixo possuirá a função de liberar o ping porém sob condições específicas:

- A CHAIN de OUTPUT permitirá apenas a saída de pacotes icmp do tipo 8 ou seja **icmp request**;
- A CHAIN de INPUT permitirá apenas a entrada de pacotes icmp do tipo 0 ou seja **icmp reply**;

```sh
# iptables -t filter -A INPUT -p icmp --icmp-type 0 -s 0/0 -j ACCEPT
# iptables -t filter -A OUTPUT -p icmp --icmp-type 8 -d 0/0 -j ACCEPT
```

> Consequencia: Em nosso cenário apenas será liberado a saída de ping, um cliente externo simplesmente NÃO poderá pingar nosso servidor, visto que o iptables simplesmente deverá "DROPAR" o recebimento do pacotes icmp do tipo Request

```sh
ping 8.8.8.8
```

Caso ache interessante você pode criar um novo conjunto de regras liberando icmp completo na rede lan, ou seja, permitindo que de dentro da rede seja possível pingar o proxy:

```sh
# iptables -t filter -A OUTPUT -p icmp -d 192.168.1.0/24 -j ACCEPT
# iptables -t filter -A INPUT -p icmp -s 192.168.1.0/24 -j ACCEPT
```

## MASQUERADE de pacotes e configuração de forward:

Configure a tabela NAT para executar o masquerade nos pacotes destinados a rede interna:

```sh
# iptables -t nat -A POSTROUTING -s 192.168.1.0/24  -d 0/0 -j MASQUERADE
```

A configuração acima apenas habilitou o MASQUERADE de pacotes utilizando nat, entretanto esses pacotes ainda terão de passar pelo firewall, consideando que nossa politica de firewall é restritiva a passagem de pacotes em si terá de ser liberada:

```sh
# iptables -t filter -A FORWARD -p tcp -m multiport -s 192.168.1.0/24 -d 0/0 --dport 80,443 -j ACCEPT
# iptables -t filter -A FORWARD -p tcp -m multiport -s 0/0 --sport 80,443 -d 192.168.1.0/24 -j ACCEPT
```

Não se esqueça das regras para liberação de acesso a porta 53:
```sh
# iptables -t filter -A FORWARD -p udp -s 192.168.1.0/24 -d 0/0 --dport 53 -j ACCEPT
# iptables -t filter -A FORWARD -p udp -s 0/0 --sport 53 -d 192.168.1.0/24 -j ACCEPT
```

## Redireciomento de portas utilizando DNAT

A ação DNAT é utilizada no iptables para redirecionamento de portas de conexão, com execução de mascaramento nat, no exemplo abaixo executamos o redirecionamento de conexões de uma porta alta do firewall para a porta 22 de um dos hosts de destino.

```sh
# iptables -t nat -A POSTROUTING -s 192.168.56.0/24  -d 0/0 -j MASQUERADE
# iptables -t nat -A PREROUTING -p tcp -i enp0s9 --dport 22000 -j DNAT --to 192.168.1.2:22
# iptables -t nat -A PREROUTING -p tcp -i enp0s9 --dport 23000 -j DNAT --to 192.168.1.3:22
# iptables -t nat -A PREROUTING -p tcp -i enp0s9 --dport 24000 -j DNAT --to 192.168.1.4:22
```

> Em cada um dos exemplos acima liberamos o PREROUTING de conexões tcp na interface reservada para ssh, utilizando a ação DNAT responsável por executar um redirecionamento de portas dentro da tabela nat, ou seja, com masquerade redirecionamos a conexão recebida na porta alta para a porta 22 de um host de destino.

> Por exemplo, considere a regra de conexão na porta 22000 do ***proxy***, ao receber essa conexão ela será redirecionada para a rede lan através do proxy "caindo" na porta 22 do endereço 192.168.1.2, ou seja, pelo proxy poderiamos fazer um ssh no servidor ***mx*** sem que este possua conexão direta com a rede externa.

Como a politica do firewall é o DROP das regras de forward, precisaremos liberar a passagem de pacotes pelo firewall:

```sh
# iptables -t filter -A FORWARD -p tcp -m iprange --dst-range 192.168.1.2-192.168.1.4 --dport 22 -j ACCEPT
# iptables -t filter -A FORWARD -p tcp -m iprange --src-range 192.168.1.2-192.168.1.4 --sport 22 -j ACCEPT 
```

> Já que a passagem de pacotes pelo firewall possui três destinos diferentes ( cada uma das portas dos servidores abaixo do firewall ) então precisariamos de 4 regras de forward ou de um forward para toda a rede.

> Mas sempre tem uma terceira opção, neste caso o -m ( match ) foi utilizado novamente, dessa vez com a flag iprange para definir ranges de endereos de destino.

Para testar faça um acesso remoto ao endereço 192.168.56.11 ( porta de ssh do proxy ), especificando uma das portas altas usadas nas regras, certifique-se de que o servidor de destino dentro da lan esteja ligado.

```sh
# ssh -l suporte 192.168.56.11 -p 22000
```

## Configurando as regras necessárias para pacotes "comuns" na rede:

Geralmente alguns conjuntos de pacotes tendem a ser liberados por serem de uso comum por parte dos usuarios, em nosso exemplo vamos liberar o trafego nas portas de e-mail e ftp:

```sh
# iptables -A FORWARD -p tcp -s 192.168.1.0/24 --sport 1024:65535 -m multiport --dports 20,21 -j ACCEPT
# iptables -A FORWARD -p tcp -d 192.168.1.0/24 --dport 1024:65535 -m multiport --sports 20,21 -j ACCEPT
```

Para testar essas liberações tente conectar a partir do servidor de email no ftp da unicamp:

```sh
# ftp
> open ftp.unicamp.br 
```

Liberar as portas para os protocolos pop e imap, geralmente usuários utilizam essas portas para conexão com serviços de email externos utilizando app mobile ou outlook:

```sh
# iptables -A FORWARD -p tcp -s 192.168.1.0/24 --sport 1024:65535 -m multiport --dports 110,995,143,993 -j ACCEPT -m comment --comment "Lberar imap e pop"
# iptables -A FORWARD -p tcp -d 192.168.1.0/24 --dport 1024:65535 -m multiport --sports 110,995,143,993 -j ACCEPT -m comment --comment "Liberar imap e pop"
```

> As duas regras criadas acima utilizaram comentarios através do match "comment", o comentario inserido torna-se parte da regra, útil para facilitar processos de troubleshooting em regras especificas.

## Implementando controle de status de conexão no firewall:

Para testarmos o conceito de análise de estado de conexão de pacotes, utilizaremos o módulo ***state***, com um exemplo simples: Liberar o servidor proxy para outgoing de ssh:

```sh
# iptables -t filter -A OUTPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
# iptables -t filter -A INPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
```

> Na regra de outgoing ( OUTPUT ) criada acima aceitamos a ***saída*** de qualquer pacote sob os estados ***NEW*** e ***ESTABLISHED*** com destino a porta 22, ou seja, pacotes que já estabeleceram uma conexão e pacotes novos com destino a porta que por padrão é usada para ssh serão permitidos.

> Na regra de incoming ( INPUT ) criada acima aceitados a ***entrada*** de qualquer pacote sob o estado ***ESTABLISHED***, vindo da porta 22 de qualquer origem, repare que a regra NÃO contempla tentativas de conexões no firewall uma vez que só pacotes de conexões já estabelecidas são aceitos, eis um exemplo onde o uso do controle de pacotes por estado aumenta a eficiẽncia do controle executado via iptables.


## Configurando inicialização automatica do firewall

As regras de iptables criadas em nossos exemplos foram configuradas pelo frontend iptables que "entrega" as regras diretamente no netfilter, isso quer dizer que após um processo de reboot todas essas regras teriam de ser recriadas novamente, para que isso ocorra de forma automatica é necessário que as regras sejam carregadas na inicialização do sistema.

Em geral essa configuração de inicialização é feita manualmente criando scripts de inicialização de iptables, o processo varia de acordo com o sistema de inicialização utilizado, systemD, systemV ou upstart, em nosso exemplo estamos utilizando o systemD, ele possui um pacote que automativa esse processo, o que facilitara nosso trabalho:

```sh
# yum install iptables-services
# head /etc/sysconfig/iptables
``` 

O pacote iptables-services cria uma unidade de inicialização de regras iptables no systemD, repare que as regras podem ser manualmente carregas dentro do arquivo ***/etc/sysconfig/iptables***, exatamente o que faremos a seguir:

```sh
# iptables-save > /etc/sysconfig/iptables
```

Feito isso faça um teste inicializando o serviço de iptables:

```sh
# systemctl start iptables
# systemctl status iptables
# iptables -S
```

Com o serviço configurado para controle via systemD basta garantirmos a inicialização automatica do serviço:
```sh
# systemctl enable iptables
```

## Material de Referência sobre a iptables, firewallD e systemD:

* [Página do projeto iptables](https://www.netfilter.org/projects/iptables/)

* [Overview sobre o sistema de inicialização systemD](https://access.redhat.com/articles/754933)

----

**Free Software, Hell Yeah!**
