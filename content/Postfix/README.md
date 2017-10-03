![alt tag](https://raw.githubusercontent.com/wiki/helcorin/fiapLinux/images/Postfix_logo.png)

Fonte: [https://commons.wikimedia.org/wiki/File:Postfix_mailserver_flags_by_mimooh.svg](https://commons.wikimedia.org/wiki/File:Postfix_mailserver_flags_by_mimooh.svg).

# Postfix

***Conceitos sobre serviços e Protocolos para Transferência de Mensagens;***

## Conceito

**O que é um MTA?**

Mail Transport Agent (MTA) é o servidor de e-mails propriamente dito. É a parte mais importante de um sistema de correio. Ele é o responsável pelo recebimento das mensagens e assegurar que essas mensagens cheguem ao seus destinos. Temos como exemplos de MTA: o Exim (padrão do Debian) , Sendmail (Antigo padrão RedHat), Qmail, Postfix e o Microsoft Exchange (proprietário) .

**O que é um MUA?**

Mail User Agent (MUA) é o nome designado para o programa cliente de e-mail. Podemos citar como exemplos o Thunderbird , Evolution e o Microsoft Outlook

**O que é um MDA?**

Mail Delivery Agente (MDA) é um intermediário entre o MTA e o MUA. Ele é usado para aplicar filtros antispam, remover vírus em anexos e fazer encaminhamento de
e-mails para outros endereços. Exemplos de MDA: Procmail, Fetchmail, Binmail, Dovecot, Maildrop, Postdrop etc.

O modelo abaixo demonstra o relacionamento entre cada um desses elementos:

![alt tag](https://raw.githubusercontent.com/wiki/fiap2trc/services/images/650px-MTA-MDA-MUA_relationship.svg.png)

---

## Principais Protocolos Envolvidos

**SMTP**

O protocolo SMTP - Simple Mail Transfer Protocol é o protocolo padrão para transferência de mensagens de correio eletrônico entre emissor e receptor, nesse caso ambas as partes ou seja ambos os MTAs deverão estar ligados e acessíveis a partir do processo de resolução de nomes para records do tipo MX;

Importante: Utilizamos o SMTP para envio e recebimento de mensagens e não no processo de extração para os usuários, este processo é feito utilizando outros protocolos criados com essa finalidade como IMAP e POP;

***POP***

Post Office Protocol - O POP é um dos protocolos responsáveis pelo processo de transferência de mensagens para armazenamento em um computador pessoal, O pop ficou conhecido pela característica de apagar as mensagens do servidor após a transferência, embora esse método já não seja mais tão usado hoje em dia;

***IMAP***

Internet Message Access Protocol - O IMAP também é um protocolo de correio eletrônico utilizado para transferência e armazenamento porém atuando com algumas características que o tornam superior ao POP nos aspectos de segurança e gerenciamento, o IMAP nativamente já permite o armazenamento de mensagens sem que sejam baixadas para o navegador, apresentando o cabeçalho dessas mensagens aos clientes até que seja solicitado o download;

---

## Instalando e Configurando o Postfix

Para começar executaremos a instalação do Postfix na vm/instancia dedicada para esta aula:

```sh
# sudo apt update
# sudo apt install postfix procmail bsd-mailx telnet
```

> Durante o processo de Instalação você será questionado sobre algumas opções, na primeira tela selecione ***"Internet site*** e logo após coloque o nome do servidor, ou seja, o FQDN do dominio, por exmeplo mx-pf0925.fiap.site ( Utilize seu RM para compor o FQDN no formato "mx-rmXXXXx.fiap.site" );

---

## Configurando o main.cf com o comando postconf

Os arquivos de configuração do "Postfix", podem ser encontrados no diretório "/etc/postfix", onde os seus principais arquivos são:

main.cf - Arquivo principal do "Postfix"onde ficam todas as configurações principais relacionadas ao funcionamento do "Postfix".

master.cf - É o arquivo que controla a ação de cada "daemon"do "Postfix". Usado para informar quantos processos "smtpd" estarão em execução, por exemplo. Caso tenhamos uma estrutura grande de máquina, uma ajuste nesses "daemons" serão bem compensadores em termos de performance.


### Editando o main.cf:

O arquivo main.cf, a configuração deste arquivo pode ser executada manualmente ou em nosso caso utilizando um utilitário de linha de comando chamado postconf, indo por esta segunda linha execute a configuração conforme abaixo, cada uma das linhas executadas foi comentada para facilitar o entendimento:

```sh
postconf -e "smtpd_banner = Bem Vindo - \$myhostname"
```

> Saudação exibida ao receber conexões smtp, uma boa prática relacionada a segurança é que este Banner não exibida informações de arquitetura como a versão do Postfix ou do Sistema Operacional;

```sh
postconf -e "mydestination = \$myhostname, localhost, \$mydomain"
```

> A opção mydestination informará quais os dominios locais sob controle do postfix, ou seja, as mesnagens endereçadas a estes dominios deverão ser entregues no próprio servidor;

```sh
postconf -e "mynetworks = 127.0.0.1/32 172.X.X.X/20"
```

> Neste ponto estamos informando quais redes poderão fazer relay no seu servidor, essa configuração ajudará a evitar que o seu servidor seja utilizado por spammers;


```sh
postconf -e "inet_interfaces = all"
```

> Definição de quais interfaces de rede serão utilizadas pelo postfix ( Caso o servidor possua mais de uma interface ativa ), neste caso a palavra chave "all" foi utilizada para definir que todas as interfaces ativas na vm/instancia poderão ser utilizadas;

```sh
postconf -e "mydomain = $(hostname -d)"
```

> Definição do dominio de internet do postfix;

```sh
postconf -e "myorigin = /etc/mailname"
```

> A configuração de origem é utilizada para definição e qualificação de endereços de email que não possuam domínio definido;

```sh
postconf -e "myhostname = $(hostname -f)"
```

Após finalizar a configuração faça o reload do psotfix:

```sh
# systemctl reload postfix
# systemctl status postfix
```

> Definição do hsotname da máquina, ou seja, o host + dominio utilizado, configure este parametro com base na saida do comando "hostname -f" ou redefina o hostname da maquina a partir do valor requerido e aplicado no postconf.

---

## Testando o envio de e-mails:

Para nosso primeiro teste de envio utilizaremos o cliente mail conforme abaixo:

```sh
echo "Teste de envio" | mail -s "Teste" suporte@$(hostname -d)
```

---

## Comandos relevantes de SMTP

**HELO:** Este é o primeiro comando enviado ao estabelecer uma conexão SMTP, sua função é a idenificação do emissor da mensagem para o receptor antes do início da transmissão da mensagem.

**FROM:** Identificação do emissor da mensagem para o servidor rodando o MTA via protocolo SMTP o endereço do emissor entra como parâmetro entre os sinais "<" e ">"  como em nosso e exemplo:

```sh
FROM: <foo@fiap.edu.br>
```

**RCPT TO:** Identificação do Destinatário para recebimento da mensagem, a exemplo do comando FROM a informação é inserida entre os sinais "<" e ">" como no modelo:

```sh
RCPT TO: <root@fiap.edu.br>
```

**DATA:** Determina o início do processo de transferência da mensagem, a partir dessa instrução o conteúdo do e-mail em si poderá ser escrito, a finalização da mensagem será repreeentada por um ponto "." ( Ponto ).

 Entre com uma nova linha e adicione este único caractere. O servidor deverá aceitar a mensagem enviando o código 250.

**QUIT:** Determina o final do processo de envio, o servidor SMTP deverá retornar o código "250 OK" fechando o canal de comunicação;


Para entender as mensagens de retorno do protocolo SMTP utilize como base duas RFCs de referencia:

- [RFC5321](https://tools.ietf.org/html/rfc5321);
- [RFC5322](https://www.ietf.org/rfc/rfc5322.txt);


O exemplo a seguir utiliza o telnet para realizar envio de e-mails utilizando comandos SMTP, para isso proceda conforme abaixo:

```sh
root@hostname:~# telnet localhost 25
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
220 Bem Vindo - fiap.edu.br
HELO mail.fiap.edu.br
250 mail.fiap.edu.br
MAIL FROM: <root@fiap.edu.br>
250 2.1.0 Ok
RCPT TO: <suporte@fiap.edu.br>
250 2.1.5 Ok
DATA
354 End data with <CR><LF>.<CR><LF>
From: Nome do Remetente <root@fiap.edu.br>

To: Nome do Destinatario <ubuntu@fiap.edu.br>
Subject: Teste de Comandos SMTP
E-mail teste - Comandos SMTP
.
250 2.0.0 Ok: queued as 53E923E957
QUIT
221 2.0.0 Bye
Connection closed by foreign host.
```

# Ativando POP e IMAP no servidor

Conforme descrito no começo desse capítulo o POP é um dos protocolos utilizados pelo usuário para Download de mensagens do servidor para o computador local, em sua configuração padrão o POP opera na porta 110, sem criptografia e na  porta 995 com criptografia de dados

Outro protocolo mais robusto e com a mesma finalidade é o IMAP, ele foi projetado para atender a uma demanda que até então não era suportada pelo POP o armazenamento de mensagens para acesso a partir de qualquer lugar e não para Download e remoção do servidor. O IMAP destaca-se pelas possibilidades de implementação utilizando TLS e consequentemente pela melhoria na camada de segurança, o protocolo trabalha utilizando a porta 993 para TLS e 143 para conexão sem criptografia.

## Instalando o POP e o IMAP

Para executar o processo de instalação de ambos os protocolos execute o comando abaixo:

```sh
# apt install courier-authdaemon courier-authlib courier-base courier-imap courier-pop -y
```

Em seguida edite o arquivo de configuração do Postfix e comente a linha abaixo:

```sh
vim /etc/postfix/main.cf 

...
# mailbox_command = procmail -a "$EXTENSION"
...
```

Ao final do mesmo arquivo de configuração adicionar os seguintes parâmetros:

```sh
home_mailbox = Maildir/
DEFAULT=$HOME/Maildir/
MAILDIR=$HOME/Maildir/
```

Reinicie o Postifix para aplicar as novas configurações:

```sh
# systemctl restart postfix
# systemctl status postfix
```

# Criando as caixas de entrada:

Na configuração anterior redefinimos o padrão para caixa de entrada para a home de usuário, para testarmos esse modelo será necessário utilizar o maildirmake para criação da caixa de entrada, neste exemplo tanto para o root como para o usuário suporte:

```sh
# maildirmake /home/suporte/Maildir
# maildirmake /home/suporte/Maildir/.Enviados
# maildirmake /home/suporte/Maildir/.Rascunhos
# maildirmake /home/suporte/Maildir/.Lixeira
# maildirmake /home/suporte/Maildir/.Spam
# chown -R suporte: /home/suporte
```

Para terminar a configuração, reinicie os serviços abaixo:

```sh
# systemctl restart courier-authdaemon
# systemctl restart courier-imap
# systemctl restart courier-pop
# systemctl restart postfix
```

Para validar o processo verifique se as portas 110 e 443 foram abertas:

```sh
ss -ntpl | egrep "110|143"
```

## Testando o protocolo POP: 

Faça um novo teste enviando mais um email para o usuário suporte e recuperando a mensagem via POP conforme squencia abaixo:


Envie um email utilizando o mail -s:

```sh
# echo "Testtando o POP" | mail -s "Teste" suporte@fiap.edu.br
```

Acesse a caixa postal no Postfix via POP

```sh
telnet mail.fiap.edu.br 110
```

Utilize os comandos abaixo para recuperar a mensagem:

```sh
user suporte
pass suporte
retr 1
quit
```

> Já os testes via IMAP faremos via MUA com Thunderbird ou implementando o RoundCube como solução de webmail;

--- 


## Material de Referência:

Material de referência publicado por [Gabriel Araujo](http://blog.4linux.com.br/author/gabriel-araujo/) no Blog da 4Linux sobre configuração de Relay de email:

- [Faça relay com Postfix e adicione HA em seus projetos](http://blog.4linux.com.br/2017/06/postfix-relay/)

---

**Free Software, Hell Yeah!**
