##### Fiap - Soluções em Redes para ambientes Linux
profhelder.pereira@fiap.com.br

---

## Instalação do Serviço

Existem algumas boas opções de projetos opensource que oferecem sistema de DNS, para nosso escopo utilizaremos o Bind fornecido e mantido pela [ISC](https://www.isc.org/downloads/bind/), esta é sem duvidas a solução mais utilizada e consequente provavelmente aquela que oferece melhor suporte da comunidade e documentação online. Mas fica uma menção 

No host dns-master instale os pacotes necessários para o bind9 e para as ferramentas de consulta:

```sh
# apt-get update
# apt-get install bind9 dnsutils bind9-doc
```

Para ambientes da familia RedHat o processo de instalação utiliza os seguintes pacotes:

```sh
# yum install bind bind-utils
```

## Configurando um DNS "Caching-Only"

Ao finalizar o processo de instalação acima o bind é entregue com a configuração "caching only", esta configuração consiste exatamente no que seu nome diz; Estabelecer o DNS como um recurso para caching de requisições dentro de uma rede sem que este atue como SOA de algum domínio.

Para testar essa implementação primeiro inicialize o serviço bind9 nos servidores Ubuntu:

```sh
# service bind9 start
```

Redirecione seu DNS para o localhost alterando o arquivo resolv.conf:

```sh
# echo "nameserver 127.0.0.1" > /etc/resolv.conf
```

Em seguida faça um teste simples utilizando o comando dig:

```sh
# dig www.fiap.com.br
```

Ao executar o dig verifique duas informações:

1. O campo **"Query time:"** apresentara o tempo necessário no processo de resolução de nomes;
2. O campo **"SERVER:"** apresenta o servidor DNS consultado, em nosso exemplo 127.0.0.1 na porta 53;
3. Ao rodar novamente o mesmo teste de resolução de nomes o Query time deverá ser reduzido drasticamente uma vez que o resultado da consulta já está em cache no bind9;

## Estrutura base do bind9 na familia Debian

No Ubuntu a estrutura do bind9 utiliza um arquivo base de configuração chamado **named.conf**, basicamnente este arquivo é um apontamento para outros arquivos com finalidades específicas:

```sh
# cat /etc/bind/named.conf
```

- **named.conf.local:** Utilizado para adicionar configurações locais no DNS;
- **named.conf.options:** Utilizado para customizar opções de segurança, repasse de requisições e localização dos arquivos de registro, na configuração padrão da familia Debian esta localização aponta para o diretório "/var/cache/bind";
- **named.conf.default-zones:** Utilizado para declarar as zonas de DNS sob controle do bind9;

A primeira entrada do arquivo "named.conf.default-zones" contém uma zona do tipo hint que aponta quais são os root servers a serem utilizados no processo de resolução de nomes, verifique o conteúdo deste arquivo:

```sh
# cat /etc/bind/db.root
# dig L.ROOT-SERVERS.NET
```

> A relação recebida na consulta acima representa o cluster de servidores DNS responsáveis pela composição do cluster
> do root server "L.ROOT-SERVERS.NET" um dos 13 root servers que compoem a infra-estrutura de DNS, alias a relação completa 
> destes servidores pode ser consultado neste [MAPA](http://www.root-servers.org/).

---

## Deploy de configuranção do bind como SOA de uma zona:

O exemplo anterior serviu para esquentar um pouco e para entendermos a estrutura basica do bind, para este laboratório executaremos o processo de configuração do bind como SOA "Start of Authority" do domínio fictício fiap.com.br.

1 - Verifique se o pacote bind está instalado no ambiente ubuntu, caso não esteja execute a instalação e em seguida abra o arquivo de configuração de zonas ***named.conf.local***:

```sh
# apt-get install bind9
# vim /etc/bind/named.conf.local
```

> Lembre-se para algumas distribuições o arquivo original é o arquivo named.conf, no caso da familia Debian optou-se por utilizar uma hierarquia organizacional onde recomenda-se que as zonas sejam alocadas no arquivo named.conf.local e as opções de configuração e segurança no arquivo named.conf.options.

Adicione o trecho abaixo no arquivo de configuracao de zonas

```sh
zone "fiap.com.br" {
        type master;
        file "/var/cache/bind/db.fiap.com.br";
};

zone "1.168.192.in-addr.arpa" {
        type master;
        file "/var/cache/bind/rev.fiap.com.br";
};
```

As linhas acima descrevem o seguinte:

1. A Zona a ser configurada é a zona ***fiap.com.br***, a string ***zone*** declara que inicamos a configuração de uma nova zona;
2. O tipo de zona escolhido foi ***master*** ou seja, esse será o DNS principla resposnável pela zona
3. Outros DNS tambem poderão responder por essa zona porem como tipo ***slave***, faremos isso em breve
4. O campo file determina one está o arquivo de zona, usamos a PATH completa apenas para fins didaticos pois, o diretório "/var/cache/bbind/" é a pasta default para armazenar arquivo de zona cofigurada automaticamente na instalação do bind9.
5. A segunda zona configurada trata-se de uma zona reversa para resolução de nomes na rede local.

Configure a zona fiap.com.br conforme o padrão salvo no repositorio git da aula (  Arquivo [db.fiap.com.br](https://raw.githubusercontent.com/fiap2trc/services/master/DNS/Debian/db.fiap.com.br) ),
Detalhes sobre cada tipo de ponteiro e sua funcao estao em comentarios no final do proprio arquivo de zona.

```sh
# vim /var/cache/bind/db.fiap.com.br
```

Verifique a zona criada utilizando o comando de checagem named-checkzone:

```sh
# named-checkzone fiap.com.br /var/cache/bind/db.fiap.com.br
```

Após finalizar as configurações e testes execute a reinicialização do serviço:

```sh
# systemctl restart bind9
```

Verifique se o serviço foi reinicializado sem problemas, ( Como ainda não configuramos o reverso o log deverá acusar essa situação ).

```sh
# systemctl status bind9
```

Verifique se o resolve.conf aponta para seu proprio servidor e inicie os testes de sua zona usando o comando host:

```sh
# host gateway.fiap.com.br
# dig @127.0.0.1 proxy.fiap.com.br +short 
```

Faça novos testes com o comando dig verificando respectviamente:

- Os ponteiros SOA;
- Os ponteiros NS;
- Ponteiros reversos;
- Acesso a partir do endereço de rede ao prcoesso de resolução de nomes.

```sh
# dig -t SOA fiap.com.br
# dig -t NS fiap.com.br
# dig -t x 192.168.56.3
# dig @192.168.56.3 web.fiap.com.br
```

### Limitando consultas e processos recursivos no bind:

Em casos onde um servidor DNS esteja operando fora da uma rede local, alguns recrusso de seugrança são importantes, um deles é desabilitar a opção de recursão, pois isto evitará abusos, como por exemplo, algum host utilizar o servidor para fazer consultas de DNSpara outros dominios;

Para executar essa configuração iremos simplesmente especificar o seguinte: 
- Quais dominios podem executar consultas ao nosso DNS  ***allow-query***
- Quais dominios podem executar consultas recursivas através da opção ***allow-recursive***

Configure o arquivo named.conf.options conforme o modelo armazenado no repositório git da aula ( Arquivo [named.conf.options](https://raw.githubusercontent.com/fiap2trc/services/master/DNS/Debian/named.conf.options) ).

```sh
# vim /etc/bind/named.conf.options
# service bind9 restart
```

### Configuracao do DNS secundário ( zona slave ):

Para esta etapa criaremos uma configuração de DNS secundário para a zona fiap.com.br, nesse processo utilizaremos um host da família RedHat o que altera em alguns detalhes a localização dos arquivos e os padrões a serem aplicados:

> Para registrarmos um domínio público, precisamos de pelo menos dois servidores "DNS" respondendo pelo seu domínio. Isso significa um servidor master e pelo menos um servidor slave. A exigência é uma forma de garantir que seu domínio estará sempre disponível.
> Essa configuração é executada com base em declarações de zona, sendo assim, um mesmo servidor rodando BIND pode ser ao mesmo tempo master para alguns domínios, slave para outros, e "cache" para todo o resto.

Inicie o processo de configuração instalando o bind9 em um servidor da Familia RedHat

```sh
# yum install bind bind-utils
# vim /etc/named.conf
```

Abra o arquivo de configuração de zonas e adicione a configuração de zona abaixo:

```sh
zone "fiap.com.br" IN {
        type slave;
        file "slave.rv.fiap.com.br";
        masters { 192.168.56.3; };
};

zone "1.168.192.in-addr.arpa" IN {
        type slave;
        file "slave.db.fiap.com.br";
        masters { 192.168.56.3; };
};
```

Reinicie o serviço de DNS:

```sh
# systemctl restart named
# systemctl status named
```

***Importante:*** Para que a trasnferência de zona funcione corretamente seu firewall deverá estar devidamente configurado permitindo conexões entre qualquer porta alta do servidor slave ( origem da requisição ) e a porta 53 do servidor de destino o DNS master, Essas regras deverão ser criadas para os protocolos TCP/UDP e considerando as CHAINs de INPUT e OUTPUT.

Faça os testes de resolução de nomes abaixo:

```sh
# dig @127.0.0.1 ftp.fiap.com.br +short
# dig @192.168.56.4 gateway.fiap.com.br +short
# dig @192.168.56.4 fiap.com.br +short
```

Você também pode se preocupar em executar alguns processos de Hardening restringindo recursão e transferência  de zona conforme as configurações documentadas [Neste exemplo](https://raw.githubusercontent.com/fiap2trc/services/master/DNS/RedHat/named.conf);

---

# Extras:

## Multiplas entradas para serviços de e-mail

É comum que se utilize mais de um backend de email para aumentar a disponibilidade de seu serviço, para que isso funcione seu DNS deverá prover algum mecanismo de balanceamento de carga entre todos os apontamentos criados, Por padrão utilizamos a definição de preferência do apontamento do tipo MX, essa configuração está prevista e descrita na [rfc974](https://github.com/2TRCR/DNS/blob/master/rfcs/rfc974.txt);

Basicamente cada entrada do tipo MX corresponde a um nome de domínio com dois pedaços de dados, uma refere-se ao valor de preferência (um 16-bit inteiro sem sinal), e o outro refere-se ao nome de um anfitrião, um domínio ou um endereço referente a um backend de email, O número de preferência é usado para indicar em que ordem o serviço de MTA deve tentar entregar a mensagem para os anfitriões MX, sempre do menor para o maior, ou seja, a menor entrada numerada refere-se ao MX s ser usado primeiro. Várias entradas MXs com a mesma preferências são permitidas e têm a mesma prioridade.

Essa configuração deverá ser executada neste formato:

```sh
mta1	IN	MX	10 mta1.fiap.com.br
mta2	IN	MX	10 mta2.fiap.com.br
mta3	IN	MX	20 mta3.fiap.com.br
mta4	IN	MX	30 mta3.fiap.com.br
```

Por exemplo, considere os apontamentos de e-mail do yahoo e do google:

```sh
# dig -t MX gmail.com
# dig -t MX yahoo.com
```

Uma abordagem alternativa é definir vários registros A com o mesmo nome do servidor de correio, algo no formato abaixo:


mail	IN	A	192.168.56.6
			192.168.56.7
			192.168.56.8


## Ponteiros do tipo Round Robin

Supondo que você deseja aumentar a disponibilidade em um serviço como uma página de conteúdo, você simplesmente poderia definir vários registros A com o mesmo nome e diferentes endereços IPs como no exemplo acima, esse tipo de entrada recebe o nome de RoundRobin ou entrada do tipo RR;

Em tempo o bind9 também suporta que simplesmente sejam criadas varias entradas com a mesma origem:

```sh
ftp	IN	A	192.168.56.3
ftp	IN	A	192.168.56.4
ftp	IN	A	192.168.56.5
```

> Esse modelo de configuração estabelece multiplos ponteiros porem sem que seja executado qualquer balanceamento de carga entre eles, logo, não se trata de um LoadBalancer em sua proposta.


## Balanceamento de requisições com ponteiros SRV

Conteúdo baseado no artigo publicado em [fogonacaixadagua](http://www.fogonacaixadagua.com.br/2009/09/dns-srv-records-com-bind/), Sim o nome é bizarro mas o artigo é muito bom ;)

Entradas do tipo SRV são utlizadas em serviços de DNS principalmente por aplicações responsáveis por backends de autenticação de usuários como os protocolos LDAP e Kerberos mas podem ser encotradas em outros protocolos como o NTP e XMPP embora com menor frequencia.

Basicamente a estrutura de um entrada do tipo SRV é composta da seguinte forma:

***<< _Serviço._Proto.Name TTL Classe SRV Prioridade Peso Porta Destino >>***

Onde:

- Serviço: nome simbólico para o serviço
- Proto: protocolo do serviço; usualmente é TCP ou UDP.
- Name: o domínio para o qual a entrada é válida
- TTL: Time to live da entrada
- Classe: sempre é IN nesse caso
- Prioridade: a prioridade para o host de destino, valores menores significam maior preferência.
- Peso: um peso relativo à entrada com a mesma prioridade
- Porta: oa porta UDP ou TCP na qual o serviço será encontrado.
- Destino: é a entrada do DNS para o host que está provendo o serviço.

Na pratica teriamos algo mais ou menos assim:

***<<_sip._tcp.fiap.com.br. 86400 IN SRV 0 5 5060 192.168.56.10 >>***

Onde entra o balanceamento de carga? No fato de que assim como as entradas RR um ponteiros SRV não precisa ser unico, aliases ou CNAMEs não podem ser usados como destinos válidos e neste contexto podemos alterar o valor dos campos Peso e Prioridade para assim criar nosso esquema de balanceamento de carga:

```sh
_sip._tcp.fiap.com.br. 86400 IN SRV 10 50 5060 192.168.56.10
_sip._tcp.fiap.com.br. 86400 IN SRV 10 40 5060 192.168.56.11
_sip._tcp.fiap.com.br. 86400 IN SRV 20 50 5060 192.168.56.12
_sip._tcp.fiap.com.br. 86400 IN SRV 20 50 5060 192.168.56.12
_sip._tcp.fiap.com.br. 86400 IN SRV 20 0 5060 192.168.56.13
```

1. No contexto acima adicionei duas entradas com prioridade 10, porém dentre elas uma delas possui peso superior, logo o servidor 192.168.56.10 deverá receber algo em otrno de 60% das requisições enquanto o servidor 192.168.56.11 receberá 40%.

2. Se ambos os servidores ( .10 e .11 ) estiverem indisponíveis os servidor 192.168.56.12 e 192.168.56.13 deverão receber essas requisições com uma balanceameno  igual de carga; 

3. De forma analoga o servidor 192.168.1.14 fará o mesmo caso os 4 servidores anteriores estiverem offline.

> Aqui já podemos falar em balanceamento de carga porém de forma limitada uma vez que a informação é estática, ou seja, não há monitoração responsável por remover um servidor da lista caso ele esteja inascesível, apenas existem ponteiros SRV determinando a prioridade na tentativa de acesso, além disso, a carga dos servidores em questão também não é levado em conta pelo bind9.
