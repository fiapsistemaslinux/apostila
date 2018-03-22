# Laboratório: Instalando a ferrametna de monitoramento de tráfego Ntopng no CentOS7

## Introdução

O Ntopng é um sistema de monitoramento de tráfego de rede de código aberto escrito com base em PHP e Lua que fornece uma interface Web para monitoramento de rede em tempo real, esta ferramenta também será o nosso primeiro contato com a implementação de um serviço controlado via [System-D](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/chap-managing_services_with_systemd);

![alt tag](https://raw.githubusercontent.com/helcorin/images/ntopng-1.png)

Este laboratório destina-se a configurar o Ntopng no CentOS7;

***Recursos do Ntopng:***

- Análise em tempo real em nível de protocolo do tráfego de rede local;
- Geolocalização de endereços IP;
- Matriz de tráfego de rede;
- Análise histórica de tráfego;
- Suporte para sFlow, NetFlow e IPFIX através do nProbe;
- Suporte IPv6;

## Instalação

A versão mais recente do Ntopng não está disponível no repositório padrão do CentOS 7, dessa forma você precisará adicionar o repositório EPEL ao seu sistema executando o seguinte comando:

```sh
sudo yum install epel-release
```

Em seguida adicione o repositório ntop.repo para ser usado como fonte para download de pacotes do ntop:

```sh
[ntop]
name=ntop packages
baseurl=http://www.nmon.net/centos-stable/$releasever/$basearch/
enabled=1
gpgcheck=1
gpgkey=http://www.nmon.net/centos-stable/RPM-GPG-KEY-deri
[ntop-noarch]
name=ntop packages
baseurl=http://www.nmon.net/centos-stable/$releasever/noarch/
enabled=1
gpgcheck=1
gpgkey=http://www.nmon.net/centos-stable/RPM-GPG-KEY-deri
```

Tendo adicionado o repositório instale o Ntopng:

```sh
sudo yum --enablerepo=epel install redis ntopng
```

Uma vez instalado, utilizaremos o pacote **hiredis-devel** e iniciar o servidor:

```sh
sudo yum --enablerepo=epel install hiredis-devel
```

## Controlando o Serviço do Ntop

O pacote Ntop fornece um serviço de monitoração, este serviço atua como um processo em execução no background do sistema operacional sendo controlado pela ferramenta de gerenciamento de serviços [System-D](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/chap-managing_services_with_systemd), dessa forma é necessário inicializar o serviço usando o systemD:

```sh
sudo systemctl start redis.service
sudo systemctl start ntopng.service
```

Verifique se o serviço foi inicializado corretamente executando o comando abaixo:

```sh
sudo systemctl status ntopng
```

## Permitir Ntopng no Firewall do servidor

A interface Web do Ntopng escuta conexões na porta TCP 3000, dessa forma é preciso verificar se essa porta está aberta para conexões e caso não esteja adicionar uma regra de firewall para essa finalidade, essa troubleshoting pode ser feito de várias formas, abaixo um exemplo de uma abordagem possível para tentar solucionar o problema:

1. Para verificar se a porta 3000 pode receber conexões execute uma chacagem usando netcat ou telnet:

```sh
# Checando a conexão com netcat:
nc -v -z <IP-DA-INTERFACE-DE-REDE> -p <PORTA TCP>

# Checando a conexão com telnet:
telnet <IP-DA-INTERFACE-DE-REDE>:<PORTA TCP>
```

2. Caso a conexão não esteja ativa verifique se o serviço do Ntop realmente criou o socket, faça essa verificação utilizando ss ou netstat:

```sh
# Verificando sockets em estado "listening" usando "ss":
sudo ss -ntpl

# Executando a mesma verificação usando o "netstat":
sudo netstat -ntpl
```

3. Com base nas verificações anteriores é possível inferir se o processo responsável pelo Ntopng realmente abriu o socket de contexão e se a conexão está em "Listening", caso seja essa a situação verifique se não existem regras aplicadas usando iptables:

```sh
sudo iptables -nL
```

Sim existe um firewall local em execução, trata-se de uma solução implementada a partir do CentOS7 chamada FirewallD, com isso você precisará adicionar uma regra de firewall para acessar o ntopng na interface de rede, você pode fazer isso executando o seguinte comando:

```sh
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --reload
```

4. Repita os testes anteriores para garantir que a solução aplicada foi efetiva:

```sh
# Checando a conexão com netcat:
nc -v -z <IP-DA-INTERFACE-DE-REDE> -p <PORTA TCP>

# Checando a conexão com telnet:
telnet <IP-DA-INTERFACE-DE-REDE>:<PORTA TCP>
```

## Testando o Ntopng:

Após configurar você pode acessar a interface da Web ntopng em um navegador da web acessando a URL "http: //<IP-DA-INTERFACE-DE-REDE>:3000" 

![alt tag](https://raw.githubusercontent.com/helcorin/images/ntopng-2.png)

Utilize as informações de login abaixo:

Usuário: **admin**
Senha:   **admin**

---

## Desafio Técnico | Garantindo a inicialização automática do Serviço

O SystemD pode ser configurado para inicializar automaticamente a solução apoś o boot do servidor, descubra como habilitar esse recurso a partir do manual do comando e execute esta configuração.

---

## Material de Referência e Recomendações:

* [Install Ntopng Network Traffic Monitoring Tool on CentOS 7](https://devops.profitbricks.com/tutorials/install-ntopng-network-traffic-monitoring-tool-on-centos-7/);

---

**Free Software, Hell Yeah!**