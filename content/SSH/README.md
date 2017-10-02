[[images/ssh_logo.png]]

## Acesso remoto entre servidores Linux

O ssh como agente de acesso remoto é uma ferramenta existente na grande maioria dos servidores e depende de um terminal de comandos e algumas opções simples, sua sintaxe básica envolve o seguinte formato:

***ssh <opções> <home_usuario_remoto>@<ip_servidor >***

O passo a passo de uma conexão via ssh deverá ocorrer conforme abaixo:

[[images/ssh_exec.png]]

> O SSH utiliza em sua configuração padrão o algoritmo de criptografia de dados RSA, considerado o melhor método já implementado para autenticação de chaves.

### Por Que o SSH é considerado um protocolo tão seguro?

O SSH é considerado seguro por utilizar algumas funcionalidades de transmissão e autenticação de usuários, provavelmente a principal dessas funcionalidades é o sistema de chaves criptográficas, onde uma chave criptográfica pública é utilizada para autenticar um computador remoto, Esse sistema de chaves também pode ser utilizado para autenticar usuários no sistema.

[[images/ssh_exec2.png]]

> Existem sistemas de comunicação que não utilizam criptografia como por exemplo o FTP e o TELNET, o SSH surgiu como uma alternativa a este tipo de sistema.

No caso de sistemas não criptografados uma variedade de ferramentas podem ser usadas para romper ou interceptar dados comunicação com o objetivo de conseguir acesso, como por exemplo, o uso de um sniffer para capturar dados que estão trafegando na rede.

Com o SSH essa ameaça é quase nula, isso porque o cliente e o servidor SSH usam assinaturas digitais para verificar a sua identidade. Além disso, toda a comunicação entre eles é criptografada. As tentativas para falsificar a identidade de cada lado de uma comunicação não funciona, já que cada pacote é criptografado utilizando uma chave conhecida apenas pelo cliente e o servidor

[[images/ssh_exec3.png]]

> O SSH utiliza em sua configuração padrão o algoritmo de criptografia de dados RSA, considerado o melhor método já implementado para autenticação de chaves.

## Conexão entre terminais via ssh

Neste exemplo faremos um acesso remoto do servidor, para isso basta uma senha de acesso e o endereço IP do servidor ao qual pretende se conectar, v erifique qual usuario você está utilizando atualmente e em seguida faça o acesso remoto:

```sh
whoami
ssh suporte@192.168.X.X
```

No exemplo abaixo utilize a opção “-l“, trata-se de outra forma de fazer o mesmo acesso:

```sh
logout
ssh -l suporte 192.168.X.X
```

Caso você não inclua o nome do usuários a ser utilizado no login remoto o sistema assumirá o seu nome de usuário, ou seja, um acesso partindo de um usuário chamado “suporte” tentará autenticação no servidor remoto utilizando o usuário suporte também:

```sh
logout
su – suporte
ssh 192.168.X.X -v
```

> A opção “-v” facilita os processos de acesso ao executar toda a conexão e mformato “verbose” com saida em tela.

Você pode utilizar o ssh para enviar comandos simplesmente passando um comando na frente do comando usado na conexão:

```sh
ssh suporte@192.168.X.X ip a
```

### Comandos Avançados de Acesso Remoto

Uma função interessante do acesso remoto é a transferência de arquivos via SSH, isso pode ser feito através do comando scp, neste exemplo criaremos um arquivo cobaia no host local e em seguida o enviaremos para o host remoto:

```sh
echo “OpenSource” > arquivo.txt
ssh  arquivo.txt suporte@192.168.X.X
```

Conecte-se no servidor e verifique:

```sh
ssh suporte@192.168.X.X cat ~/arquivo.txt
```

Outra possibilidade é fazer o inverso, a partir de um determinado host “puxar” um arquivo vindo de outro via scp, neste exemplo estou trazendo o arquivo hosts do host remoto:

```sh
scp suporte@192.168.X.X :/etc/hosts /tmp
ls /tmp
```

Para cópiar diretórios inteiros podemos utilizar a opção “-r” na frente do comando scp:

```sh
scp -r suporte@192.168.X.X:/etc /tmp
ls /tmp/etc
```

---

## Fazendo acesso do Windows

Caso não esteja trabalhando em um sistema Linux ou em um Mac OS então você não possuirá um terminal de onde iniciar sua conexão SSH, ou seja, para usuários Microsoft Windows a coisa muda um pouco, precisaremos de ferramentas que auxiliem no acesso remoto:

---

### Conhecendo o putty

Uma das opções em relação a acesso remoto a partir de ambientes windows é a ferramenta [putty](www.putty.org/);

O putty é um executável, por isso não é preciso efetuar a instalação, ao abrir a aplicação preencha os campos “Host Name”  e Port com os nomes do host e da porta do servidor onde pretende efetuar a conexão:

[[images/putty-1.png]]

> Geralmente o ssh utiliza a porta 22 como porta padrão porém qualquer porta acima de 1024 também poderá ser usada.

No primeiro acesso você verá a tela ao lado, sempre que ouver uma primeira tentativa de acesso será solicitado que você aceite a identificação do servidor, informação que será armazenada em uma base de dados com o nome dos hosts conhecidos, ou seja, dos endereços que já acessou, clique em “sim” para que essa identificação ocorra.

[[images/putty-2.png]]

---

### O cliente Bitvise

Uma solução para acesso remoto via windows derivada do putty, é o Bitvise, este é com certeza uma ferramenta útil principalmente por não se limitar apenas a fornecer sessões de login no terminal e permitir também a trasnferẽncia de arquivos, o bitvise pode ser obtido no mesmo endereço do [putty](http://www.putty.org);

[[images/bitvise-1.png]]

---

### O cliente RemoteNG

Aqui uma terceira opção para usuários do windows, o RemoteNG é um projeto interessante por permitir criação e armazenamento de perfis de configuração de acesso, onde o acesso a multiplos hosts pode ser configurado de forma a agilizar o acesso quando necessário, vale a pena se você utiliza o SSH com frequência a partir de hosts windows para multiplos hosts GNU/Linux, o projeto pode ser obitdo no site [mremoteng.com](https://mremoteng.org/download);

[[images/mRemoteNG_1.jpg]]

---

## SSH com Chaves Assimétricas

Além da autenticação via senhas o SSH provê um mecanismo de autetnicação baseado em acesso remoto via chaves, para isso é possivel gerar pares de chaves (publica/privada) através do comando **ssh-keygen**;

O ssh-keygen é o comando reponsável por gerar os arquivos de chavesm,  ***.ssh/id_rsa*** e ***.ssh/id_rsa.pub*** respectivamente a chave privada e a chave pública.

```sh
ssh-keygen
ls $HOME/.ssh
```

>  O arquivo ***$HOME/.ssh/id_rsa*** é a sua chave privada e consquentemente um arquivo restrito cuja permissão deve ser obrigatoriamente ***600***, para evitar que outros usuários do sistema possam lê-lo, muitos sistemas recusam a conexão caso os arquivos estejam com as permissões abertas.

### Uso de frase passe:

Quando executar o ssh-keygen você será questionado sobre o uso de uma passphrase, trata-se de um recurso extra de segurança, quando cadastrada a frase passe sera solicitada no momento do acesso remoto.

A ***frase passe*** é uma senha que pode ir desde uma senha em texto "normal" com caracteres, até uma frase complexa, sem limite de tamanho; o importante é que não seja algo fácil de adivinhar. Caso a passphrase não seja definida o acesso remoto será sem senha.

### Copiando as chaves para o destino:

Após gerar as chaves você deverá copiar a ***chave pública*** gerada para o servidor que deseja acessar remotamente, o uso dessa chave substituirá o mecanismo de autenticação com usuário e senha.

```sh
ssh-copy-id -i ~/.ssh/id_rsa.pub suporte@192.168.X.X
```

> A opção “-i” especifica a chave publica a ser copiada para o destino, caso a chave esteja no diretório padrão do usuário ( .ssh ) e com a nomenclatura padrão ( id_rsa.pub ) então essa opção poderá ser omitida.

Faça un novo acesso a partir do uusário dono da chave para o servidor de destino:

```sh
ssh suporte@192.168.X.X
```

> Verifique que a chave foi criada na home do usuário corrente que executou o comando ssh-keygen, e ao enviar com o ssh-copy-id especificamos o usuário de destino que recebeu a chave.

---

## Configurações especificas para acesso remoto:

serviço SSH utiliza dois arquivos de configuração:

- /etc/ssh_config: Responsável pela configurações de opções dos clientes de SSH, ou seja opções a serem utilizadas pelo serviço ssh ao tentar se cominucar com um servidor de destino.

- /etc/sshd_config: Arquivo de configuração do deamon de ssh, o ssh server responsável por aceitar uma conexão e estabelecer uma sessão, em geral a maioria das opções referentes as conexões remota e segurança podem ser configuradas aqui. Aqui poderiamso limitar quais usuários podem se conectar remotamente, a porta utilizada pelo serviços etc.

Para nosso exemplo considere a alteração nas configurações de ssh conforme abaixo:

```sh
vim /etc/ssh/sshd_config

...

Port 2000

#AddressFamily any
ListenAddress 192.168.X.

...

#LoginGraceTime 2m
PermitRootLogin yes
#StrictModes yes
...

```

Neste exemplo três opções foram alteradas: 

1. Mudança da porta padrão 22 para acesso pela porta 2000,
2. Restrição de acessos unicamente para conexões a partir da subrede 192.168.X.*
3. Liberação de acesso via usuário root, por padrão algo bloqueado em sistemas Red Hat/CentOS.

Importante: Ao executar alterações nesses arquivos é necessário que o serviço seja reinicializado, neste exemplo estamos considerando que o deamon utilizado é o SystemD:

```sh
systemctl restart sshd
```

Verifique que a porta de conexão no host de destino foi alterada:

```sh
nc -z -v -w 5 192.168.X.X 22
nc: connect to 192.168.X.X port 22 (tcp) failed: Connection refused
```

Repita a verificação utilizando a porta alta configurada:

```sh
nc -z -v -w 5 192.168.X.X 2000
Connection to 192.168..X.X 2000 port [tcp/cisco-sccp] succeeded!
```

Faça os testes executando uma conexão no servidor onde as alterações foram realizadas utilizando o usuário root ( Se necessário que antes você defina uma senha para o usuário root utiliznado o comando passwd ).

```sh
ssh root@192.168.X.X -p 2000
```

> Como a porta de acesso não é mais a porta default a opção -p deverá ser usada para definir o uso da porta 2000;

---

[[images/ssh-keys.jpg]]

## Opções de Hardening para o SSH

Em servidores onde a conexão SSH é por algum motivo aberta para a acesso a partir de qualquer endereço externo a segurança torna-se uma questão mais complexa e complicada em seu gerenciamento, nesse ponto algumas opções podem ser consideradas:

### Configuração e uso de recursos do próprio deamon:

A primeira e mais importante ação a se tomar é atentar-se para como a configuração do deamon de SSH e do uso de chaves foi estabelecida, ou seja, uma correta politica de configuração é em si um forte recurso de defesa, neste ponto considerar os passos abaixo:

1. Acessos diretos utilizando o usuário root com certeza devem ser bloqueados a partir da opção de configuração ***PermitRootLogin***

2. Também é possível estabelecer quais usuários e quais grupos podem executar SSH utilizando a opção ***AllowUsers*** e ***AllowGroups***

3. Outra questão é o uso de chaves, uma opção para evitar tentativas de [Brute Force](https://www.owasp.org/index.php/Brute_force_attack) é desabilitar o acesso usuando senhas com a opção ***PasswordAuthentication***

4. Ainda referente ao uso de chaves temos a "passphrase", esse recurso melhora sua segurança uma vez que para conseguir o acesso será necessário que o usuário possua a chave privada relacionada a chave publica adicionada ao host de destino e o conhecimento da "passphrase", essa frase é adicionada no momento de criação da chave conforme o exemplo abaixo:

```sh
ssh-keygen

Generating public/private rsa key pair.
Enter file in which to save the key (/home/suporte/.ssh/id_rsa): 
Created directory '/home/suporte/.ssh'.
Enter passphrase (empty for no passphrase): 

```

5. Finalmente a questão mais simples, **utilizar sempre a ultima versão do pacote que provê o deamon de ssh** 

> Falhas de segurança e vulnerabilidades surgem com frequência, embora não seja um método infalível o uso da ultima versão do protocolo disponível para sua distro diminui consideravelmente a probabilidade de que uma falha na implementação torne-se um vetor para ataque, vide o caso referente ao virus Wanna-Cry e sua ação em versõe do Windows onde o ultimo pack do WIndows update não fora aplicado.

6. Automatizar e orquestrar o delivery de configurações de segurança:

Uma boa dica para garantir boa parte dessas configurações, princiaplmente aquelas referente a configuração do Deamon de SSH e de atualizações de versões de pacotes é o uso de algum recurso de automação/orquestração como as soluções abaixo: 

* [Puppet](https://puppet.com/);
* [Chef](https://www.chef.io/chef/);
* [Salt](https://saltstack.com/);
* [Ansible](https://www.ansible.com/);

[[images/automation-tools.png]]

Todas essas soluções possuem recursos especificos para lidar com a entrega de chaves e configurações de acesso remoto.

---

[[images/tfa-ssh-google.png]]

### Usando TFA com Google Authenticator

Existem varias implementações de TFA que podem ser implementadas a partir de uma configuração aplicada no PAM, o recurso responspavel pela autenticação de usuarios em sistemas GNU/Linux, uma vez que um recurso de TFA seja implementado ele pode ser utilizado no processo de acesso remoto o que aumenta consideravelmente a segurança princiaplmente se combinado ao uso de chaves.

No site da Digital Ocean existem bons tutoriais demonstrando essa implementação em plataformas Ubuntu e Centos:

* [How To Set Up Multi-Factor Authentication for SSH on CentOS 7](https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-centos-7);

* [How To Set Up Multi-Factor Authentication for SSH on Ubuntu 16.04](https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-ubuntu-16-04);

Este segundo exemplo do linode apresenta como executar a configuração de TFA baseado também em Centos7:

* [Use One-Time Passwords for Two-Factor Authentication with SSH on CentOS 7](https://www.linode.com/docs/security/use-one-time-passwords-for-two-factor-authentication-with-ssh-on-centos-7); 

---

[[images/portknocking.png]]

### Usando o Port Knocking:

O Port Knocking é uma implementação de segurança que permite estabelecer o controle de acesso a portas utilizando firewall iptables com o objetivo de obfuscar a porta de conexão diminuindo o vetor para tentativas de Brute Force e uso de ferramentas automatizadas, colocando de forma bem simples ao implementar o Port Knocking podemos criar um segredo, uma relação de portas a serem acessadas como requisito para que o acesso a porta de SSH seja liberado.

Vale a pena dar uma olhada no projeto, a Digital Ocean e o Portal Cyberciti possuem boas referências sobre o assunto:

- [How To Use Port Knocking to Hide your SSH Daemon from Attackers on Ubunt](https://www.digitalocean.com/community/tutorials/how-to-use-port-knocking-to-hide-your-ssh-daemon-from-attackers-on-ubuntu);

- [Tutorial port-Knocking Cyberciti](https://www.cyberciti.biz/faq/debian-ubuntu-linux-iptables-knockd-port-knocking-tutorial/);

Para usuários da Familia RedHat segue o tutorial criado no Tecadmin:

- [How to Secure SSH Connections with Port Knocking on Linux CentOS](https://tecadmin.net/secure-ssh-connections-with-port-knocking-linux/#);

---

[[images/fail2ban.png]]

### Usando o Fail2ban:

Outra opção muito conhecida é o [Fail2ban](https://www.fail2ban.org), que possui o nome mais auto explicativo de todos, a solução é muito conhecida por seu uso na área de VoIP com Asterix mas pode ser facilamente adptada ao Hardening de SSH;

Novamente a Digital Ocean oferece um ótimo tutorial sobre como implementar o Fail2ban baseado em Centos7:

- [How To Protect SSH With Fail2Ban on CentOS 7](https://www.digitalocean.com/community/tutorials/how-to-protect-ssh-with-fail2ban-on-centos-7);

Para implementações com base na familia Debian encontrei um bom material no site da Kyup:

- [How to protect SSH with fail2ban](https://kyup.com/tutorials/protect-ssh-fail2ban/);

Já essa DOC da paltaforma de Cloud Linode demonstra o mesmo principio utilizando multiplas distribuições:

- [Using Fail2ban to Secure Your Server](https://www.linode.com/docs/security/using-fail2ban-for-security);

---

## Material de Referência sobre SSH:

No link abaixo um artigo publicado na digital ocean detalha algumas opções úteis para customização e alterações de segurança no SSH e sobre um outro recursos de segurança chamado TCP Wrappers, vale uma olhadela.

- [How To Tune your SSH Daemon Configuration on a Linux VPS](https://www.digitalocean.com/community/tutorials/how-to-tune-your-ssh-daemon-configuration-on-a-linux-vps)

---

**Free Software, Hell Yeah!**
