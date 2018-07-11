##### Fiap - Soluções em Redes para ambientes Linux
profhelder.pereira@fiap.com.br

![alt tag](https://github.com/fiapsistemaslinux/apostila/raw/master/images/apache-0.png)

---

O projeto Apache é um esforço comunitário de desenvolvedores cujo objetivo é prover um servidor web de código fonte aberto, estável e seguro. Sua origem está em um projeto da NSCA (Nacional Center of Supercomputing Aplications) criado pelo desenvolvedor de softwares e arquiteto de aplicações Robert M. McCool. O projeto inicial foi retomado por desenvolvedores dando origem a Fundação Apache (Apache Foudation).

Você encontrará um detalhamento maior dessas informações no site do projeto o [apache.org](http://www.apache.org)

### Histórico

A primeira versão do Apache foi lançada em 1995, sendo que a partir de 1996 o projeto ganhou grande reconhecimento e popularidade, hoje em dia pode se dizer sem chances de erro que o Apache é ainda hoje, a maior e uma das mais usadas soluções em relação a disponibilização de sites na internet. Essa informação pode ser aferida atráves do site [NetCraft](https://news.netcraft.com/) conforme abaixo:

![alt tag](https://github.com/fiapsistemaslinux/apostila/raw/master/images/apache-1.png)

> O gráfico dispoe informações sobre a fatia de uso de cada um dos principais projetos de Servidor de Conteúdo Web, aqui vemos o Apache liderando a preferência dos desenvolvedores sendo seguido de perto pelo IIS da Microsoft e pelo promissor NGINX.

***Principais vantagens do Apache:***

- O projeto está sobre licença GPL, ou seja, Software Livre, podendo ser estudado, modificado, adaptado e redistribuído;
- Suporta várias linguagens de programação como "PHP", "Python", "Ruby", "Perl" e inclusive "ASP" e ".NET";
- Aplicação Multiplataforma podendo ser implementado em Unix, Linux ou Windows;
- Pode trabalhar com multi "threads", isto é, MultiProcessamento, uma funcionalidade disponível apartir de sua segunda versão o Apache2;
- Tratase de uma aplicação Modular, você libera os módulos (funcionalidades) de acordo com sua necessidade;## Modulos de operação

Para dominar o apache um dos primeiros conceitos a serem entendidos é a questão dos MPM`s (Multi-Processing Modules) ou módulos de multi-processamento do servidor, estes módulos podem ser entendidos como duas opções diferentes de configuração para o Apache, são eles o módulo PreFork e o módulo Worker. Um deles lhe concederá compatibilidade com algumas linguagens de programação mais antigas e o outro fornecerá otimização na performance do servidor e consequentemente de sua aplicação.

### MPM Pré-Fork

Neste modo, o Apache trabalhará com a implementação de multi-processos, onde um processo será responsável por executar novos processos que serão utilizados para aguardar novas conexões e responder as requisições existentes. Este modo é ideal para quem precisa manter compatibilidade com aplicações e bibliotecas que ***NÃO SUPORTAM*** o método de operação conhecido como Worker.

### MPM Worker

No modo de Operação conhecido como "MPM Worker", o Apache trabalhará com uma implementação mista de processos e "threads", o que possibilita atender mais conexões simultâneas com um custo menor de hardware, já que "threads" são mais velozes que processos.

Neste modo de operação, o apache mantém uma série de "threads" ociosas, fazendo com que novas conexões sejam processadas e respondidas de uma maneira mais rápida do que no modo "Pre Fork". Infelizmente nem toda aplicação se dá bem com "threads", como o "PHP5", por exemplo.

---

## Deploy de um servidor de conteúdo:

Nos processos que seguem executaremos a instalação e configuração do apache2 em ambiente Ubuntu, adicionaremos suporte a PHP para executarmos alguns deploys de aplicações opensource, para isso começe pela instalação dos pacotes básicos:

### Executando instalação do apache2

```sh
apt update && apt install apache2 curl
```

No processo acima executamos uma instalação simples do apache, verifique o funcionamento do serviço executando o seguinte:

```sh
systemctl start apache2
ss -ntpl
```

Caso sua instalação tenha sido finalizada com sucesso e caso o acesso a partir da porta 80 esteja OK você já deverá ser capaz de visualizar uma página em CSS com conteúdo default entregue pela instalação, esse conteúdo localiza-se no diretório raiz que armazena o conteúdo do site, chamamos esse diretório de ***DocumentRoot***, no Ubuntu trata-se do diretório ***/var/www/html***

Se o seu acesso estiver bloqueado por qualquer motivo você ainda pode acessar localmente no terminal de comandos pelo curl ou tunnelar uma porta ssh 

```sh
curl --verbose 127.0.0.1
```

> Na execução acima tome como base que estamos rodando uma distro derivada da Familia Debian, o apache assim como o bind9 possui grandes variações na sua nomenclatura, caso ele seja executado na Familia RedHat o demon do serviço seria o httpd, mesmo nome a ser utilizado na instalação do pacote via yum;

> Outra variação esperada é relativa ao caminho da instalação, aqui (Debian/Ubuntu) sua configuração esta distribuida dentro da pasta /etc/apache2 enquanto no RedHat a estrutura basei-se na pasta /etc/httpd.

### Estrutura do apache na Familia Debian

Desconsiderando variações específicas que ocorrem na implementação entre uma versão da distro e outra o layout geral da configuração do apache na instalação em um sistema operacional da Familia Debian é o seguinte:

```sh
/etc/apache2/
├── apache2.conf
├── conf-available
├── conf-enabled
├── envvars
├── magic
├── mods-available
├── mods-enabled
├── ports.conf
├── sites-available
└── sites-enabled
```


***apache2.conf:*** Principal arquivo de configuração. Esse arquivo agrada cada configuração aplicada ao apache, incluindo todos os arquivos de configuração restantes indicados por funções de include iniciar o servidor web;

***ports.conf:*** Na familia Debian esse arquivo é sempre incluído a partir do arquivo de configuração principal. Ele é usado para determinar as portas de escuta para conexões de entrada, em outras distros esses parametros em geral se encontram dentro do arquivo de configuração principal;

***mods-enabled /, conf-enabled / e sites-enabled / :*** Diretórios que contêm determinados trechos de configuração para gerenciamneto de módulos, o que facilita no modelo de gestão modular proposto pelo projeto, aqui encontram-se fragmentos de configuração global ou configurações de hosts virtuais do apache.

 ***mods-available /, conf-available / e sites-available / :*** São os diretórios responsáveis por alocar as configurações ativam, cada um deles é populado por links simbólicos para outros diretórios de configuração , os diretórios citados anteriormente com o nome "*-enable".

> Esses links simbólicos alocados nos diretórios "*-available" devem ser gerenciados usando os comandos a2enmod, a2dismod, a2ensite, a2dissite e a2enconf, a2disconf, o modelo é exclusivo da Família Debian/Ubuntu... parece complicado mas após o primeiro teste você pega o jeito!

### Gerência de configurações com o comando apache2ctl:

Na familia Debian o apache utiliza um binário de configuração chamado apache2ctl:

```sh
apache2ctl -h
```

A patir deste binário é possível executar diversas ações como por exemplo testar a configuração atual de seu servidor ou efetuar um restart:

```sh
apache2ctl configtest
apache2ctl restart
apache2ctl fullstatus
```

Existem situações em que talvez não seja interessante efetuar um restart direto no seu servidor, isso porque o comando reinicializaria todas as conexões, inclusive aquelas ativas o que em um ambiente em produção poderia ser sentido pelo usuoario acessando sua aplicação. Para isso o apache utiliza um modelo de restart do tipo ***gracefull*** que permite reinicilizar o serviço aos pocuos, aguardando até que os processo em aberto seja finalizado:

```sh
apache2ctl graceful
```

> A diferença entre este comando e os anteriores é que neste caso o servidor não irá finalizar todos os processos e conexões para subir uma nova configuração, ele simplesmente irá iniciar novas conexões com as alterações em vigor sem matar as antigas, ou seja, sem que haja qualquer impacto na aplicação.

### Virtualhosts

O termo Virtual Host refere-se à pratica de rodar mais de um site em um único host, ou seja, hospedar e acessar duas páginas diferentes hospedadas no mesmo servidor utilizando registros de DNS para que o apache saiba qual conteúdo deve entregar, na prática hosts virtuais também podem ser "baseadas em IP", o que significa que você tem um endereço IP diferente para cada site, mas o mais comum é utilizaor o DNS, o que também significa ter vários nomes de domínio em execução em cada endereço IP. Ao utilizar um Virtual Host o fato de ter dois ou mais sites em execução no mesmo servidor físico não é aparente para o usuário final.

> O Apache foi um dos primeiros servidores de conteúdo a suportar hosts virtuais e possui uma forte documentação sobre o assunto no [site oficial do projeto](https://httpd.apache.org/docs/2.4/vhosts/);

#### Configurando virtualhosts no apache

A configuração de um virtual host no projeto apache é executada a partir da função [<VirtualHost>](https://httpd.apache.org/docs/2.4/mod/core.html#virtualhost) sendo que o local de sua declaração varia de acordo com a implementação do apache ( Existem diferenças sobre onde declarar um virtual host nas familias Debian e RedHat );

Para este exemplo faremos a configuração do Virtual Host para delivery de um [template](https://github.com/fiapsistemaslinux/apostila/blob/master/content/Apache/templates/cloud.tar.bz2) utilizando uma implementação 2.4 do apache no ubuntu server, para começar garanta a existencia do template no DocumentRoot do apache em /var/www/

No Ubuntu o apache utiliza o diretório /etc/apache2/sites-available como base para criação de virtual hosts, acesse esse diretório e crie um arquivo chamado [001-openstack.conf](https://raw.githubusercontent.com/fiapsistemaslinux/apostila/master/content/Apache/vhosts/001-cloud.conf)

Outros exemplos de criação de virtual hosts podém ser acessados [AQUI](https://httpd.apache.org/docs/2.4/vhosts/examples.html)

```sh
vim /etc/apache2/sites-available/001-cloud.conf
```

Após criar um Virtual Host será necessário ativa-lo para isso utilize o comando a2ensite ou crie manualmente um link simbolico entre o arquivo criado e um arquivo de mesmo no na pasta sites-enabled

```sh
a2entise 001-cloud
service apache2 reload
```

Faça um teste acessando o conteúdo de seu site pelo Server Name ou por um dos Server Alias que utilizou ao criar o seu VirtualHost, Não se esqueça, o apache não cria as entradas de DNS para o domínio desejado, logo você terá de fazer isso manualmente adicionando um registro em seu servidor de DNS;

No nosso caso temos a opção de forçar um HEADER na requisição a partir do próprio sistema operacional utilizando o nome de DNS ou FQDN esperado pela aplicação conforme o exemplo abaixo:

```sh
curl -v -H 'Host: cloud.fiapdev.com' http://127.0.0.1:80
```

---

# Configurando conteúdo usando Apache com Criptografia HTTPS

![alt tag](https://github.com/fiapsistemaslinux/apostila/raw/master/images/apache-2.jpg)

O uso do protocolo SSL no apache cria uma configuração que permite trafegar dados sensíveis e confidenciais com segurança através da internet, o [TLS](https://en.wikipedia.org/wiki/Transport_Layer_Security#Security) (Transport Layer Security) e o seu antecessor o SSL (Secure Socket Layer) são protocolos que encriptam toda a transmissão entre o cliente e o servidor de conteúdo, Sites de comércio eletrônico e páginas de autenticação ou que envolvam qualquer outro tipo de informação confidencial utilizam essa camada de segurança (atualmente sempre TLS en detrimento do SSL), alias hoje em dia QUALQUER tipo de site DEVE utilizar criptografi, essa decisão envolve fatores como segurança e até um tipo de padronização que vem sendo estabelecido por gigantes como o Google, verifique as notas de rodapé sobre o assunto.

## Conceitos

Para entender um pouco melhor o funcionamento do TLS começemos pelo básico, o uso de certificados digitais:

***1. O que é um certificado Digital?***

Um certificado digital é um arquivo que contém um conjunto de informações referentes a uma entidade, isto é a empresa, pessoa ou recurso para qual o certificado foi emitido.

***2. Como os certificados funcionam?***

Um certificado digital funciona de forma semelhante a um documento de identificação como um passaporte ou carteira de motorista, geralmente um certificado contêm uma chave pública e a identidade da entidade proprietária. Eles são emitidos por autoridades de certificação (CAs), que devem validar a identidade do titular do certificado, tanto antes da emissão do certificado quanto quando um certificado é usado.

***3. Sobre as autoridades de certificação:***

A Autoridade de Certificação (CA) é a organização ou sistema responsável por emitir certificados digitais, mas além disso também é a organização responsável por garantir sua validade, ou seja, é a autoridade certificadora quem valida se a chave pública apresentada na comunicação usando o protocolo SSL ( Essa chave é "apresentada" através do certificado digital emitido pela CA ) pertence à pessoa, organização ou entidade cujas informações estão contidas no certificado.

***4. Como criar um certificado:***

Um certificado pode ser criado utilizando o comando openssl conforme veremos a seguir, depois de criar o certificado, você poderá enviá-lo a uma unidade certificadora, por exemplo a Serasa Experian, VeriSign, CertSign, ACBR, Serpro, entre outras, essa unidade fará o processo de assinatura do certificado, sendo geralmente cobrado um valor  anual ou bienal pelo serviço, essa autoridade passa a ser a responsavel por validar o certificado conforme descrito no item 3.

***5. Ceritifcados auto assinados:***

Você também pode atuar como uma CA e auto assinar seu certificado, porém neste cenário os navegadores de internet não serão capazes de validar seu certificado, assim no processo de negociação o protocolo SSL não será capaz de executar o reconhecimento completo do certificado, o que deverá exibir no navegador aquela mensagem do tipo "Sua Conexão não é particular" ou "Existe um problema com o certificado de segurança deste web site" pois este não foi assinado por uma unidade certificadora.

Colocando em linhas gerais e sem detalhamento técnico o processo de validação de um certificado utilizando o protocolo TLS ocorre conforme abaixo:

![alt tag](https://github.com/fiapsistemaslinux/apostila/raw/master/images/tls-1.jpg)


O processo simplificado acima é o processo conhecido como Three-Way-Handshake e está menos simplificado e um pouco melhor detalhado aqui:

![alt tag](https://github.com/fiapsistemaslinux/apostila/raw/master/images/tls-1.gif)


Informações mais detalhadas sobre esse processo podem ser obtidas [Neste link](https://sites.google.com/site/ddmwsst/digital-certificates#TOC-What-is-a-Digital-Certificate) e no conteúdo da [Apostila direcionado para Criptografia](https://github.com/fiapsistemaslinux/apostila/tree/master/content/Criptografia);

---

## Habilitando criptografia no apache2

O suporte ao uso de criptografia é um recurso modular nativo do apache bastantdo apenas que seja habilitado, para isso execute:

```sh
# a2enmod ssl
# service apache2 restart
```

Verifique se o protocolo foi realmente habilitado listando os módulos em uso e verificando a porta 443:

```sh
# apache2ctl -M
# netstat -ntpl
```

> Tenha em mente que o comando usado habilita o suporte a criptografia em geral ou seja tanto o modelo atual usando TLS quanto o modelo mais defasado usando SSL, a definição de qual o protocolo a ser usado na comunicação fica por conta do conjunto de cifras, outro conteúdo disponível no conteúdo da [Apostila direcionado para Criptografia](https://github.com/fiapsistemaslinux/apostila/tree/master/content/Criptografia);


## Configurando um certificado auto assinado:

Primeiro criamos a nossa chave de 4096 bytes para assinar o certifcado:

```sh
# openssl genrsa -out /etc/ssl/private/apache-selfsigned.key 4096
```

Com a chave em “mãos”, crie um certificado, algumas informações serão requeridas, você pode "facilitar" o processo populando o arquivo /etc/ssl/openssl.cnf com o [padrão](https://raw.githubusercontent.com/fiapsistemaslinux/apostila/master/content/Apache/openssl.cnf) salvo no github da disciplina.

```sh
# openssl req -new -key /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.csr
```

> É neste ponto que o certificado criado por você poderia ser enviado para assinatura por parte de uma autoridade certificadora, ou como faremos abaixo podemos auto assinalo.

Utilize o openssl para assinar o certificado com a chave criada anteriormente e validade de um ano:

```sh
# openssl x509 -req -days 365 -in /etc/ssl/certs/apache-selfsigned.csr -signkey /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt
```

Uma vez que o certificado esteja finalizado, basta criarmos uma configuração de virtual host para seu uso, para isso substitua o Vhost utilizado no template anteriomente pelo [modelo sugerido](https://raw.githubusercontent.com/fiapsistemaslinux/apostila/master/content/Apache/vhosts/001-cloud-ssl.conf) para este teste, o modelo esta cheios de comentarios para facilitar o entendimento.


Outra opção um pouco mais rápida mas muito menos didática seria executar a função de criação da chave e assinatura em um só comando:

```sh
# sudo openssl req -x509 -days 365 -newkey rsa:4096 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt
```

Habilite o modulo responsável pela função de rewrite dos acessos na porta 80 para a porta 443 e o novo VirtualHost para acesso ao site:

```sh
# a2enmod rewrite
# a2dissite 000-default
# a2dissite 001-cloud
# a2ensite 001-cloud-ssl
```

Finalizando recarregue o apache para que possamos checar nossa nova configuração:

```sh
# service apache2 reload
```

Faça os testes executando o acesso a partir de um navegador, considere que este host devera utilizar algum mapeamento ou dns para resolução de nomes no acesso ao ip do host rodando apache:

```sh
# openssl s_client -connect cloud.fiapdev.com:443
```

---

## Habilitando HSTS:

O teste a seguir refere-se ao processo de criação do header para HSTS usando o apache, para isso adicione a entrada abaixo no vhost criado anteriormente:

```sh

<IfModule mod_ssl.c>
        <VirtualHost _default_:443>

    # Header para uso de HSTS:
    Header always set Strict-Transport-Security "max-age=63072000; includeSubdomains;"

...


```

Se necessário utilizar o modelo disponível no arquivo [001-cloud-hsts.conf](https://raw.githubusercontent.com/fiapsistemaslinux/apostila/master/content/Apache/vhosts/001-cloud-hsts.conf) no repositório do projeto;

Em seguida habilite o modulo headers e faça um reload no apache:

```sh
# a2enmod headers
# service apache2 reload
```

Faça um teste simples executando um curl e verificando o header obtido:

```sh
curl --verbose --insecure -s -D https://cloud.fiapdev.com/ | grep Strict
```

O teste acima deverá exibir o cabeçalho passado na requisição, o resultado esperado é:

```sh
...

* Connection #0 to host cloud.fiapdev.com left intact
Strict-Transport-Security: max-age=63072000; includeSubdomains;

...

```
---

## Deploy de certificado HTTPS com CA válida:

![alt tag](https://github.com/fiapsistemaslinux/apostila/raw/master/images/tls-1.png)


Certificados criptografados são utilizados na criptografia da conexão entre clientes e servidores de conteúdo, a segurança em sua aplicação se da tanto pelo uso de criptografia no tráfego quanto pela confirmação de identidade, esta segunda parte está diretamente ligada ao uso de uma CA, uma autoridade certificadora válida responsável pela checagem e confirmação dos dados usados na criação do certificado bem como sua origem.

O Let`s Encrypt é um projeto gratuito que fornece um meio para instalação de um certificado usando uma CA válida sem que seja necessário atuar a partir de uma autoridade certificadora.

### Pré-Requisitos:

Para execução deste laboratório precisaremos de alguns itens e configurações específicas:

1- Um servidor rodando o sistema operacional GNU/Linux Ubuntu Server versão 16.04 e com permissões admistrativas para o seu usuário;

( O Lets Encrypt pode ser utilizado com qualqer sistema linux com suporte a openssl, neste caso o uso específico do Ubuntu é por conta dos scripts e pacotes escolhidos para execução do Lab. )

2- O servidor escolhido deverá estrar rodando o web server Apache com pelo menos um domínio configurado usando Virtual Host;

### Parte 1 — Instalando o cliente do Let's Encrypt:

Faremos o download da configuração do Let's Encrypt usando o repositório oficial do Ubuntu:

```sh
sudo apt-get update
sudo apt-get install python-letsencrypt-apache
```

### Parte 2 — Configurando o Certificado:

Faça a geração do certificado para o Apache usando a ferramenta automatizada do Let's Encrypt, o cliente executará o download e configuração do certificado automatizado:

```sh
sudo letsencrypt --apache -d devops.fiapdev.com # Neste exemplo o dominío utilizado foi "devops.fiapdev.com"
```

***Importante***:

- Para que o teste funcione é necessário que o dominio especificado seja valido e por tanto já tenha DNS totalmente configurado, além disso é necessário prover um endereço de e-mail válido durate a configuração ou atender a um tipo de desafio, que é basicamente configurar um tipo de chave no servidor de destino para acesso a partir do nome de DNS para o qual se deseja este certificado;

- No processo de instalação você será questionado em um processo passo-a-passo sobre opções de configurações do certificado, além do email você deverá escolher entre habilitar http e https ou o redirecionamento automático de páginas para https, geralmente a opção mais segura.

- Finalizando a instalação você conseguirá verificar o certificado criado a partir do diretório /etc/letsencrypt/live;

- Verifique o status de sua conexão a partir do [sslabs](https://www.ssllabs.com/ssltest);

---

### Material de Referência:

Este laboratório foi criado com base em um tutorial publicdo por [Erika Heidi](https://www.digitalocean.com/community/users/erikaheidi) na página de comunidade da Digital Ocean:

* [How To Secure Apache with Let's Encrypt on Ubuntu 16.04](https://www.digitalocean.com/community/tutorials/how-to-secure-apache-with-let-s-encrypt-on-ubuntu-16-04)

O projeto Let's Encrypt possui documentação oficial, seu Getting Started é um bom começo se pretende em implementar em algum projeto pessoal ou mesmo na empresa onde trabalha:

* [Let's Encrypt Documentation](https://letsencrypt.org/docs/);

* [Let's Encrypt Getting Started](https://letsencrypt.org/getting-started/);

Tão importante quanto entender o processo de configuração é entender a criptografia em si, para isso alguns links podem ser úteis:

* [Processo de validação de certificados, esplicados no passo a passo em detalhes](https://sites.google.com/site/ddmwsst/digital-certificates#TOC-What-is-a-Digital-Certificate)

* [Material complementar sobre o comando openssl e possibilidades de checagem e troubleshoting de certificados](https://www.feistyduck.com/library/openssl-cookbook/online/ch-testing-with-openssl.html)

---

### Documentação Oficial do Projeto:

* [SSL/TLS Strong Encryption: How-To](https://httpd.apache.org/docs/2.4/ssl/ssl_howto.html);

* [VirtualHost Examples](https://httpd.apache.org/docs/2.4/vhosts/examples.html);

* [Security Tips](https://httpd.apache.org/docs/2.4/misc/security_tips.html);

* [Apache Performance Tuning](https://httpd.apache.org/docs/2.4/misc/perf-tuning.html);

* [Server-Wide Configuration](http://httpd.apache.org/docs/current/server-wide.html);
( Este ultimo inclui as definições sobre para configuração de ServerTokens e ServerSignature );

----

**Free Software, Hell Yeah!**