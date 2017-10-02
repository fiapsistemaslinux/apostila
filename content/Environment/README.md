# Command Environment:

O terminal de comandos Linux é responsável por interpretar tarefas e traduzi-las em chamadas de sistema, para isso ele utiliza um interpretador de comandos, chamamos esse interpretador de SHELL, o conceito de Shell é bem antigo, M. Tim Jones descreve o uso das primeiras Shells de comandos em sistemas Unix no começo da década de 70; Apesar de tanto o Windows como o GNU/Linux possuirem essa mesma base como herança do  Unix, as Shells se popularizaram mais fortemente na estrutura Linux, todo sistema GNU/Linux possui uma Shell, na verdade a maioria deles possuem mais de uma, são exemplos de Shell Linux:

- bash
- sh
- zsh
- dash

No mesmo artigo Jones descreve a arquitetura base de uma shell fazendo analogia com um canal, com recebimento de entrada, interpretação e execução de comandos, o que faz sentido pois é a partir da shell que as intruções são convertidas em chamadas dentro do sistema operacional conforme o modelo abaixo:

[[images/shell-archtecture.gif]]


## Executando comandos e entendendo o Environment:

Chamamos de "Environment" o conjunto de informações mantida por uma sessão de shell aberta, para testar esse conceito abra um terminal de comandos, a distribuição escolhida e o tipo de terminal em si não importam muito nesse momento:

```sh
# /bin/bash
# echo "Essa é a famosa e tão amada shell bash"
# ls
# pwd
# whoami
# history
```

```sh
# /bin/bash
# echo "Da pra abrir uma Shell bash dentro de outra"
# cd /
# ls -R
# history
# clear
```

```sh
# sh
# echo "Essa é a shell sh ela é legal também mas diferente da bash "
# history
# cd
# pwd
```

```sh
# exit
```

Pronto, foram três sequências de comandos bem simples finalizadas por um "exit" colocado ali propositalmente pra que você percebesse que ao abrir mais de uma sessão no terminal estamos simplesmente abrindo uma shell dentro da outra, se insistir e executar o comando "exit" mais duas vezes verá que na segunda provavelmente fechará seu terminal pois já não haverá mais sessões das quais sair, além disso verifique que o histórico de execução de comandos dentro de cada sessão é diferente, isso porque essas informações são parte do chamado "Environment" e pertencem a sessão sendo gravadas em definitivo no histórico no momento em que você finaliza a sessão;

## Variaveis de Ambiente:

Outro ponto importante é sobre como invocamos a shell bash, fizemos isso usando o comando /bin/bash que aliás poderia ser simplificado para bash, eis aí uma característica importante das shells, elas permitem execução de comandos binários sem que seja necessário localizar seu caminho absoluto. Para isso utilizam o que chamamos de uma variável de ambiente;

A variável que identifica quais os locais válidos para encontrar binários quando executamos um comando é a variável $PATH

```sh
# echo $PATH
```

Verifique que o binario do comando ls encontra se em um diretório listado dentro da variável $PATH:

```sh
# which ls
# /bin/ls
```

É por isso que podemos simplesmente rodar um ls sem necessariamente passar seu caminho completo no sistema:

```sh
# ls
```

Eis outro exemplo de uma característica da shell, a declaração e o uso de variáveis;  No exemplo acima o comando "echo" seguido do caráctere "$" mais o nome da variável nos permite a visualização de seu valor, essa variável existe por default em sistemas Linux sendo declarada durante o processo de inicialização, a esse Tipo de variável damos o nome de ***variável de ambiente***.

Variáveis de Ambiente possuem diversas funções entre as mais simples está a definição de parâmetros como a sua localização atual ( variável PWD ), o usuário logado no momento ( variável USER ) ou os diretórios onde localizar binários para execução ( variável PATH );

Nem todas as variáveis de ambiente possuem valor pré definido, algumas vem "em branco" podendo ser declarada manualmente:

```sh
# echo $TIMEOUT
# TIMEOUT=30
# echo $TIMEOUT
```

A lista completa dessas variaveis de ambiente é consideravelmente longa, você pode consulta-la utilizando o comando "printenv" conforme abaixo:

```sh
# printenv
```

Para facilitar a leitura da saida utilize um paginador de conteudo: 

```sh
# printenv | less
```

Além do printenv outra opção de exibição é o uso do comando "set", este comando exibirá tanto as variaveis de ambiente quanto as funções declaradas no sistema:

```sh
# set
```

A lista abaixo foi extraida do Manual "The Linux command Line" e possui uma relação de algumas das variaveis de ambiente mais relevantes para o sysadmin:

[[images/variables-list-1.png]] 


## Como as configurações de um Environment são geradas?

Ao logar em um sistema GNU/Linux uma shell será inicializada, provavelmente a shell bash, essa shell faŕa um processo de consulta em alguns scripts de configuração que definirão as regras gerais para construção do Environment de cada usuário, ( Mesmo aqueles ainda não logados herdaram essas regras ), chamamos esses scripts de "startup files", sendo os principais deles o ***/etc/profile*** e o ***/etc/environment***.

```sh
# cat /etc/environment
# cat /etc/profile
```

> A depender da versão de sistema e do tipo de shell utilizado poderão existir outros scripts como o ***/etc/bash.bashrc*** e os arquivos dentro do diretório ***/etc/profile.d/***;

### Startup Files para sessões de usuário:

Além dos arquivos que definem regras de Environment para todo o sistema existem outros que são confinados a sessões de usuário, esses arquivos são localizados sempre dentro da home de usuário no formato oculto:

```sh
# ls -a $HOME/$USER
# ls -a /root
# cat /root/.bashrc
```

A tabela abaixo apresenta uma relação desses arquivos e sua descrição:

[[images/startup-files.png]]

Essa segunda relação refere-se aos startup files de usuários que não são diretamente ligados a um login de sessão:

[[images/startup-files-2.png]]


## Aliases de Comandos:

Outra caracteristica extremamente interessante das shells é a possibildiade de construirmos alias para execução de comandos, considere o exemplo abaixo:

```sh
# alias rede='ip -a'
# rede
```

Alias são úteis para configuração de "atalhos" na execução de comandos parametrizados, o próprio sistema faz amplo uso desse recurso para customização de comandos como ls e rm, verifique todos os alias existententes em seu sistema digitando o comando abaixo:

```sh
# alias
```

Alias podem ser removidos utilizando o comando "unlias":
```sh
# unalias rede
# alias
```

---

***Aqui vai uma dica para certificações:***

Tanto no caso da LPI quanto na RHCSA o conhecimento e domínio de  um terminal de comandos será essencial, existem perguntas específicas em ambas as provas direcionadas a configuração de variações, entrada e saída de comandos e outros itens referentes a exploração do terminal;

> O terminal de comandos de um sistema GNU/Linux é a base para execução de tarefas configuração e manutenção do modo gráfico e para operações de gerenciamento avançado, por isso é muito importante conhecer minimamente seu comportamento e saber como manipula-lo, nesse caso a pratica leva a perfeição, logo a medida que formos avançando no curso a tendência é que seu uso seja mais e mais aprofundado.

---

## Material de Referência e Recomendações:

Artigo publicado em 2011 por M. Tim Jones no IBMdeveloperworks:

 * [Evolução das Shells no Linux](https://www.ibm.com/developerworks/br/library/l-linux-shells/);

Ebook, Linux Command Line de William Shotts, Capitulo 11 – The Environment:

 * [The Linux Command Line, 11 – TThe Environment](http://linuxcommand.org/tlcl.php);

Guia Foca Linux, Capítulo 21 - Personalização do Sistema;

 * [Guia Foca Linux Online, Capítulo 11](http://www.guiafoca.org/cgs/guia/intermediario/ch-pers.html);

---

**Free Software, Hell Yeah!**
