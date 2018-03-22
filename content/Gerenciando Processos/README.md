##### Fiap - Soluções em Redes para ambientes Linux
profhelder.pereira@fiap.com.br

![alt tag](https://raw.githubusercontent.com/helcorin/images/processos-desc.png)

---

O trecho abaixo contém uma boa definição sobre processos, retirado do material de estudos utilizado pelo Professor Romildo Martins Bezerra, ( verifique a bibliografia desta aula ).

*Processo é basicamente um programa em execução sendo constituído de um código executável, dados referentes ao código, da pilha de execução, do valor do PC, do valor do apontador de pilha, dos valores dos demais registradores do hardware e outras informações. Associado a um processo está seu espaço de endereçamento, uma lista de posições de memória que contém todas as informações do processo.*

<!--
[[images/process.png]]
-->
![alt tag](https://raw.githubusercontent.com/helcorin/images/process.png)

## Listando Processos 

Para cada processo em execução o sistema atribui um PID ( Process Identifier ) ou seja um número identificador para um processo, o qual é utilizado nas operações de manipulação de processos sejam elas iniciadas pelo sistema ou pelo usuário.

```sh
# ps aux
# ps -ef
```
O comando PS é uma boa opção para verificar este PID entre outras informações sobre os processos sendo executados no sistema, executar este comando sem parãmetros listará apenas os processos do seu usuário rodando em FOREGROUND, portanto o uso mais comum é com o conjunto de opções “-aux” ou “-ef” verifique os manuais do sistema para obter dtalhes sobre estes parametros.

Tenha em mente que para cada novo processo que nasce nasce um novo PID, e NUNCA haverá um único PID para mais de um processo, existem situações dentro do sistema em que um processo gera uma cópia de si mesmo a fim de que um novo processo similar seja criado e a ele sejam atribuidas novas tarefas, o Apache por exemplo utiliza esta metodologia na maioria de suas implementações, ao processo que origina um novo processo damos o nome de PAI e ao processo criado damos o nov de filho,  o comando pstree permite uma visualização clara deste formato hierárquico:

```sh
# pstree
```

Outra maneira útil de visualizar processo é utilizando o programa top:

```sh
# top
```

Seu retorno em tela demonstrará uma relação de processos sendo executados e recursos alocados para estes prcoessos, nessa listagem a OITAVA COLUNA chamada STAT representa o estado de um prcoesso, o estado de um processo poderá assumir os seguitnes valores:

-***R:***  Processo sendo executado ( Running );
-***D:***  Processo em esperada no disco;
-***S:***  Processo suspenso no sistema ( sleeping );
-***T:***  Processo interrompido ( Por exemplo, parado manualmente com o comando kill );
-***Z:***  Processo Zumbi;

Para a maioria da distribuições Linux essas informações que listamos estão centralizadas no diretório /proc, um diretório de Kernel de conteúdo dinâmico, que possui um subdiretório para cada processo representado pelo número de seu PID:

```sh
# ls /proc
# ls /proc/1
```

> É comum pintar na LPI alguma pergunta relacionada ao processo de PID 1, este processo se chama “init”, é o PAI de todos os processos em execução no sistema Operacional.

## Sinais de um processo

Os sinais de um processo represetam ações que podem ser passadas pelo sistema ou pelo usuário, o comando kill é o principal comando uso para alterações em processos via envio de sinais:

Liste quais sinais podem ser passados pelo comando kill -l:

```sh
 1) SIGHUP	 2) SIGINT	 3) SIGQUIT	 4) SIGILL	 5) SIGTRAP
 6) SIGABRT	 7) SIGBUS	 8) SIGFPE	 9) SIGKILL	10) SIGUSR1
11) SIGSEGV	12) SIGUSR2	13) SIGPIPE	14) SIGALRM	15) SIGTERM
16) SIGSTKFLT	17) SIGCHLD	18) SIGCONT	19) SIGSTOP	20) SIGTSTP
21) SIGTTIN	22) SIGTTOU	23) SIGURG	24) SIGXCPU	25) SIGXFSZ
26) SIGVTALRM	27) SIGPROF	28) SIGWINCH	29) SIGIO	30) SIGPWR
31) SIGSYS	34) SIGRTMIN	35) SIGRTMIN+1	36) SIGRTMIN+2	37) SIGRTMIN+3
38) SIGRTMIN+4	39) SIGRTMIN+5	40) SIGRTMIN+6	41) SIGRTMIN+7	42) SIGRTMIN+8
43) SIGRTMIN+9	44) SIGRTMIN+10	45) SIGRTMIN+11	46) SIGRTMIN+12	47) SIGRTMIN+13
48) SIGRTMIN+14	49) SIGRTMIN+15	50) SIGRTMAX-14	51) SIGRTMAX-13	52) SIGRTMAX-12
53) SIGRTMAX-11	54) SIGRTMAX-10	55) SIGRTMAX-9	56) SIGRTMAX-8	57) SIGRTMAX-7
58) SIGRTMAX-6	59) SIGRTMAX-5	60) SIGRTMAX-4	61) SIGRTMAX-3	62) SIGRTMAX-2
63) SIGRTMAX-1	64) SIGRTMAX
```

Dentre os sinais que podem ser passados pelo kill os mais comuns são o -15 ( SIGTERM )  utilizado para finalizar um processo e o preferido dos sádicos o -9  ( SIGKILL ) que mata um processo de forma direta, sem finalização de subtarefas ou execução de chamadas.

Para finalizar um processo basta disparar um sinal -15 “contra” seu PID, utilize uma combinação de ps com grep para lozalizar este número, como no exemplo abaixo:

***Terminal 1:***
```sh
# sleep 300
``` 

***Terminal 2:***
```sh
# ps aux | grep sleep
ubuntu  4412  0.0  0.0  14360   712 pts/6    S+   14:08   0:00 sleep 300
ubuntu  4426  0.0  0.0  21296   936 pts/20   S+   14:08   0:00 grep --color=auto sleep
```

***Terminal 2:***
```sh
# kill -15 4412
```

> O valor -15 é o padrão usado pelo comando kill portanto pode ser omitido, já para forçar a morte de um processo “travado” geralmente utilizamos um “kill -9”.


## Netstat como recurso para gerenciar processos

O netstat é uma ótima ferramenta para gerenciamento de processos e de recursos de rede, utilizando os parâmetros certos este comando fornecerá informações sobre conexões de rede, portas abertas e processos relacionados.

Neste exemplo estou visualizando quais as conexões abertos em um servidor na AWS:

```sh
# netstat  -tu

Active Internet connections (w/o servers)
Proto Recv-Q Send-Q    Local Address              Foreign Address           State      
tcp        0      0    ip-172-31-29-79.us-:ssh    X-X-X-X.dsl.:38264        ESTABLISHED
tcp        0      0    ip-172-31-29-79.u:43584    ec2-54-214-78-213.:http   TIME_WAIT  
tcp        0      0    ip-172-31-29-79.u:54708    steelix.canonical.:http   TIME_WAIT  
tcp        0      0    ip-172-31-29-79.u:57105    ec2-54-203-130-222:http   TIME_WAIT  
tcp        0      0    ip-172-31-29-79.u:45910    keeton.canonical.c:http   TIME_WAIT
```

> A primeira linha por exemplo representa a minha conexão SSH com o servidor aberta a partir de uma porta alta ( Padrão para requisição de serviços ) com destino a porta 22 do host na AWS, verifique o manual do comando para entender cada um dos status.


Outra abordagem é utilizar a combinação de opções “pan” para verificar todos os processos utilizados no momento e seus respectivos programas/serviços, neste exemplo estou visualizando quais as conexões abertos em um servidor na AWS:

```sh
# netstat  -pan

unix  2      [ ACC ]     SEQPACKET      LISTENING       7700     493/systemd-udevd   /run/udev/control
unix  2      [ ACC ]     STREAM         LISTENING       6856     1/init              @/com/ubuntu/upstart
unix  2      [ ACC ]     STREAM         LISTENING       9115     1072/php-fpm.conf)  /var/run/php5-fpm.sock
unix  2      [ ACC ]     STREAM         LISTENING       8955     993/acpid           /var/run/acpid.socket
unix  3      [ ]         STREAM         CONNECTED       8680     1/init              
unix  3      [ ]         STREAM         CONNECTED       9021     1012/nginx          
unix  3      [ ]         STREAM         CONNECTED       8729     821/systemd-logind  
```

A lista acima foi reduzida pois seria enorme considerando que cada processo utilizando um socket de conexão foi listado, netes casos mesmo processos internos com um “sudo” podem ser visutalizados, a linha destacada é um exemplo de aplicação, um serviço web chamado NGINX inicializado pelo processo de PID 1012.

No próximo exemplo visualizemos apenas os processos com status “LISTENING” ou seja, processos que represetem conexões estabelecidas você pode alternar entre as flags “-ntpl” para conexões tcp/ip e “-nupl” para conexões udp ou simplesmente utilizar ambas “-ntupl”:

```sh
# netstat  -ntpl

Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address          Foreign Address         State       PID/Program name
tcp       0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      1012/nginx      
tcp       0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      992/sshd        
tcp6      0      0 :::22                       :::*                LISTEN      992/sshd 
```

Verifique que a saida do comando permite idenficar qual endereço de rede está sendo utilizado para receber conexões do serviço  NGINX, e novamente qual o processo relacionado a aplicação.

## Modificando o plano de um processo:

Processos do sistema podem ser executados em primeiro plano ou em segundo plano, executar um processo em segundo plano significa permitir que o kernel execute o programa sem que haja intervenção ou em alguns casos interações com o usuário e consequentemente sem que este processo esteja vinculado a sessão de usuários:

```sh
# updatedb &
# jobs
```

> Neste exemplo utilizei o comando “&” para colocar o processo do programa updatedb em segundo plano, dessa forma eu poderia continuar usando o terminal que não permaneceria ocupado ou até mesmo fechar o terminal sem que o processo fosse finalizado por conta disso, ja p comando “jobs” permitirá verificar quais programas estão rodando em Background.


Neste exemplo iniciamos o editor de textos vim em background, como trata-se de um recurso que obrigatoriamente exige interação com o usuário o editor imediatamente coloca o processo em status stopped “T”

```sh
# vim /tmp/test &
[1] 1669
[1] +  Stopped                 vim /tmp/test
```

Da pra verificar esse processo utilizando o comando jobs ou analisando o status da oitava coluna de saida da listagem do comando ps:

```sh
# jobs
[1]+  Stopped                 vim /tmp/test

# ps aux | grep vim
root      1669  0.0  0.4  39796  4676 pts/1    T     19:18   0:00   vim   /tmp/test
root      1675  0.0  0.0  10432   628 pts/1    S+    19:22   0:00   grep  --color=auto vim
```

Fechando com o comando fg pode ser utilizado para retornar um processo ao FOREGROUND de tela, o número na primeira coluna da saida do comando jobs representa o indice  do programa em background, caso haja mais de um comando podemos usar este indice para escolher qual o comando a ser “resgatado” para primeiro plano.

```sh
# fg 1
```

## Gerenciamento avançado com fuser

O fuser é um comando de gerenciamento avançado de processos, sua função é identificar processos relacionados com base no uso de arquivos ou sockets, por exemlo, vericando quais processos estão utilizando o ssh com base no nome do deamon:

```sh
# fuser ssh/tcp
```

Também da pra verificar as mesma informações com base na porta  ( considerando que você  saiba qual a porta utilizada pelo serviço sendo investigado):

```sh
# fuser -v -n tcp 22
```

### Finalizando conexões de usuário:

Neste exemplo estou localizando os processos abertos pelo usuário ubuntu, verifique que como todo usuário logado a sessão foi vinculada a um terminal ( pts/1 ):

```sh
# ps  aux | grep ubuntu

ubuntu  1886   0.0    0.1   105636     1884    ?        S     19:31    0:00    sshd: ubuntu@pts/1  
ubuntu  1887   0.0    0.3    21320     3920    pts/1    Ss    19:31    0:00    -bash
root    2012   0.0    0.0    10436     892     pts/1    S+    19:42    0:00    grep --color=auto ubuntu
```

Com base nesta informação é possivel eliminar a conexão deste usuario simplesmente matando os processos relacionados ao terminal pts/1:

```sh
# fuser -k /dev/pts/1
```

## Gerenciando processos e auditando com lsof:

O lsof é um recurso do sistema utilizado para gerenciar arquivos abertos ( list open files ), suas funções seguem a mesa linha dos comandos netstat, ss e fuser: Gerenciamento avançado de processos, da pra debugar muita coisa e facilitar o trabalho do admin utilizando o lsof, comece verificando todos os arquivos que utilizam o processo do ssh:

```sh
# lsof -c ssh
```

Verifque quais processos foram abertos pelo usuário ubuntu:

```sh
# lsof  -t -u ubuntu
```

Faça uma listagem de todas as conexões de rede abertas:

```sh
# lsof -i
```

Com base no exemplo anterior verifique quaisconexões de rede foram abertos por um processo especifico, por exemplo pelo processo do ssh:

```sh
# pgrep ssh

1743
2014
2067
```

Localizando os processos do ssh verifico com base no menor número, pela lógica da hierarquia de processos seria o processo pai da coisa toda:

```sh
# lsof -i -p 1743 -a

COMMAND  PID USER    FD  TYPE DEVICE SIZE/OFF NODE NAME
sshd    1743 root    3u  IPv4  12459      0t0  TCP *:ssh (LISTEN)
sshd    1743 root    4u  IPv6  12461      0t0  TCP *:ssh (LISTEN)
```

Listando todos os processos utilizando a porta :80

```sh
# lsof -i :80

COMMAND  PID     USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
nginx   2141     root    6u  IPv4  14454      0t0  TCP *:http (LISTEN)
nginx   2142 www-data    6u  IPv4  14454      0t0  TCP *:http (LISTEN)
nginx   2143 www-data    6u  IPv4  14454      0t0  TCP *:http (LISTEN)
nginx   2144 www-data    6u  IPv4  14454      0t0  TCP *:http (LISTEN)
nginx   2145 www-data    6u  IPv4  14454      0t0  TCP *:http (LISTEN)
```

---

## Material de Referência e Recomendações:

Parte dos exemplos anteriores de LSOF baseiam-se em um artigo publicado no site thegeekstuff, tem muito mais coisas sobre o lsof por lá:

 * [Linux lsof Command Examples](http://www.thegeekstuff.com/2012/08/lsof-command-examples/);

 * [Guia Foca Linux Online, Capítulo 7](http://www.guiafoca.org/cgs/guia/intermediario/ch-run.html);

---

**Free Software, Hell Yeah!**
