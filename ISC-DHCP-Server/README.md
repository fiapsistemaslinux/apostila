
[[images/DHCP-base.png]]

O DHCP ou 'Dynamic Host Configuration Protocol' é um protocolo de rede usado para atribuir endereços IP e fornecer informações sobre a configuração de dispositivos de rede tais como servidores, desktops ou dispositivos móveis, para que ele possam se comunicar em uma rede usando outros protocolos. O ISC DHCP é um conjunto de software que implementa todos os aspectos da suíte DHCP incluindo os seguintes itens:

 - Um cliente DHCP, que pode ser fornecido com o sistema operacional de um host ou outro dispositivo capaz de enviar requisições de configuração para o servidor. A maioria dos dispositivos e sistemas operacionais já têm clientes DHCP incluído, na maioria das implementações de Linux este cliente é o DHCLIENT.

 - Um agente de retransmissão DHCP, que passa solicitações DHCP de uma LAN para outra, de modo que não precisemos ter um servidor DHCP em cada LAN.

 - E um servidor DHCP, que recebe as solicitações dos clientes e responde a eles.


> Em nossa infra-estrutura utilizaremos o DHCP para entrega de endereçamento automatico na rede 192.168.1.X
> verificar Diagrama com mapeamento dos serviços e disposição dos servidores para mais detalhes
> a instalação será feita no servidor de Proxy e exploraremos o systemD como recurso para depurar o funcionamento
> e habilitar o carregamento automático do serviços na inicialização do sistema.
> Também executaremos testes utilizando mapeamento automatico de endereços de forma a validar esse recurso. 

Os conteúdos foram criados com base neste Layout de Redes emulado no Virtual Box, Você pode fazer o download das OVAS utilizadas no projeto a partir deste [link](https://mega.nz/#F!PUBiTQLL!u8usq56qO1RwEx5tt546Tg)

## Instalação do Serviço

Para este exemplo de implementação considere uma arquitetura utilizando um servidor Centos7 ou RedHat7 como DHCP de rede com hosts de clientes ( Linux, Windows ou MAC alocados dentro da mesma sub-rede e que receberam a configuração de rede entre pelo DHCP server:

[[images/arquitetura-DHCP.png]]

Em sistemas Linux a solução de dhcp mais utilizada é o pacote dornecido e mantido pela [ISC](https://www.isc.org/downloads/dhcp/), ele esta presente na grande maioria dos repositorios padrões dos sistemas Linux, em nosso modelo faremos a instalação deste pacote conforme os passos abaixo: 

```sh
# yum info dhcp
# yum install dhcp
```

Para distros da familia Debian o pacote a ser instalado seria o isc-dhcp-server também fornecido pela ISC:

```sh
$ apt-cache show isc-dhcp-server
```

Ao finalizar a instalação o seguinte arquivo de configuracao foi criado:

```sh
# cat /etc/dhcp/dhcpd.conf
#
# DHCP Server Configuration file.
#   see /usr/share/doc/dhcp*/dhcpd.conf.example
#   see dhcpd.conf(5) man page
#
```



## O protocolo DHCP, processo de concessão de endereços:

Entre o processo de solicitação de endereço e a concessão feita pelo servidor o protocolo DHCP opera da seguinte forma:

1. **DHCPDISCOVER** - Um cliente envia um quadro "broadcast" com um pedido "DHCP";
2. **DHCPOFFER** - O servidor captura o quadro e oferece um endereço IP ao "host" requisitante;
3. **DHCPREQUEST** - O cliente envia uma requisição de aceite "DHCP REQUEST" ( um tipo de notificação ) para o servidor "DHCP";
4. **DHCPACK** - O servidor confirma a atribuição de uma configuração de rede ao cliente, ou seja, apartir deste momento a interface de rede no host passa a possuit configurações distribuídas pelo servidor "DHCP" com um tempo de release para renovação da concessão, este valor também é atribuido segundo a configuração dada pelo servidor DHCP;

[[images/DHCP_session.png]]

O processo acima ocorre quando o host solicita um endereço IP a rede a procura de um heroico servidor DHCP para salvar o dia, tipo um conto de fadas SQN, na pratica essa solicitação pode partir do daemon de rede caso uma determinada interface esteja configurada para uso do DHCP ( Dúvidas, volte um pouco e dê uma checada na aula de redes ), outra opção é solicitar a concessão manualmente, em sistemas linux podemos fazer isso utilizando o cliente dhclient:

```sh
# dhclient <interface> -v
```  

## Configuração de um servidor DHCP

Faça uma cópia do arquivo de configuração original do DHCP:


```sh
# cd /etc/dhcp
# cp /usr/share/doc/dhcp-*/dhcpd.conf.example .
# grep -v \# dhcpd.conf.example > dhcpd.conf
# cat dhcpd.conf
```

Pronto, basicamente criamos uma cópia simples do arquivo de exemplo e em seguida um novo arquivo de configuracao sem os comentarios.

Configure o arquivo conforme este [Template](https://github.com/fiap2trc/Services/blob/master/DHCP/dhcpd.conf);

Ao finalizar inicialize o serviço utilizando o comando abaixo:

```sh
# systemctl start dhcpd
# systemctl status dhcpd
# ss -nupl
```

### Testando a configuração com concessão automatica:

Utilizando um host cliente dentro da rede onde o DHCP fora implementado execute:

```sh
# dhclient <interface> -v
# ifconfig
```

No servidor responsável pelo DHCP, Verifique novamente os logs:

```sh
# systemctl status dhcpd -l
```

Verifique que o DHCP guarda informações sobre a concessão no arquivo dhcpd.leases:

```sh
# tail /var/lib/dhcpd/dhcpd.leases
```

### Testando a configuração com concessão manual por MAC:

Libere as linhas necessarias no arquivo de configuração e cadastre o MAC ADDRESS de cada servidor para suas respectivas interfaces

Em seguida reinicialize o serviço executando o comando abaixo:

```sh
# systemctl restart dhcpd
```

Para testar repita as solicitações com dhclient respeitando sempre o nome correto para cada interface de rede;

Finalizando em um dos clientes e execute:

```sh
# dhclient -r
# dhclient <interface> -v
# ifconfig
``` 

```sh
# dhclient -r
# dhclient <interface> -v
# ip a
```
---

### Material de Referência sobre a implantação de um servidor DHCP:

Esse material foi construido com base na documentação oficial do site ISC.org:

* [Documentação oficial do isc.org](https://www.isc.org/downloads/dhcp/)

A RedHat também possui boa documentação sobre a implementação na Familia RedHat/Centos:

* [Documentação oficial da RedHat](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Networking_Guide/sec-dhcp-configuring-server.html)

---

**Free Software, Hell Yeah!**
