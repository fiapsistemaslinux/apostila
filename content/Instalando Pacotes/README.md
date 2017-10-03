![alt tag](https://raw.githubusercontent.com/wiki/helcorin/fiapLinux/images/pacotes-desc.png)

---

## Package Managers ( Gerenciadores de Pacotes ):

Uma das maneiras mais comuns de se instalar pacotes em sistemas GNU/linux é através do uso de pacotes pré compilados, um pacote pré compilado é basicamente o código fonte de uma aplicação que recebeu um tratamento espefico sendo adptado para uma familia específica de sistemas Linux, dentro dessa lǵocia utilizamos uma ferramenta para manipular este pacote, a essa ferramenta damos o nome de gerenciador, gerenciadores de pacotes são comuns na maioria das distribuições GNU/Linux de uso comercial e podem ser classificados entre ***Gerenciadores de Alto Nível*** e ***Gerenciadores de Baixo Nível***.

---

[[images/apt-distros.png]]

### Gerenciamento de pacotes com DPKG:

O DPKG ( Debian Package ) é um exempl ode gerenciador de pacote de baixo nível, essa classificação baseia-se na maneira como o gerenciador trata os pacotes, gerenciadores de baixo nível executam funções de instalação, remoção e manipulaçã ode pacotes dentro do sistema, no caso do DPKG sua operação é feita utilizando comandso em modo texto, e cosutma ser restrita a usuários avançados de sistema dado sua compelxidade.

Sendo uma aplicação nativa em ambientes Debian o DPKG sempre está disponível em praticamente todas as derivações geradas na família Debian como o Ubuntu ou o Linux Mint por exemplo, os pacotes manipulados via DPKG são chamados de debian packes e são identificados pela extenção **.deb**.

No ubuntu abra um terminal com permissões administrativa e começe com uma listagem simples dos pacotes instalados:

```sh
dpkg -l
```

Para facilitar a localização de um pacote específico você pode filtrar a informação da listagem anterior, sabendo o nome do pacote o parametro "-s" ( --status ) pode ser utilizado para obter informações sobre o pacote:

```sh
dpkg -l | grep bash
dpkg -s bash
```

Sendo um gerenciador de baixo nível o dpkg não busca pacotes na internet, logo suas operações de gerenciamento se limitam a pacotes que estejam instalados ou que foram previamente baixados, no exemplo abaixo executamos o tratamento de um pacote baixado de internet:

```sh
wget http://mirrors.kernel.org/ubuntu/pool/universe/h/htop/htop_1.0.2-3_amd64.deb
```

Verifique a extensão do pacote baixado:

```sh
file htop_1.0.2-3_amd64.deb
```

A opção “-I” ( --info ) exibe o cabeçalho de informações de um pacote .deb:

```ssh
dpkg -I htop*
```

Para executar o processo de instalação utilize a opção “-i” ( --install ):

```sh
dpkg -i htop*
```

Verifique se o pacote foi instalado:

```sh
dpkg -l | grep htop
dpkg -s htop
htop
```

Processos de remoção de pacotes podem ser executadas com a opção “-r”:

```sh
dpkg -r htop 
dpkg -l | grep htop
```

Ao instalar um pacote é comum que este possua dependências, ou seja, sua instalação trâs outros pacotes como bibliotecas e manuais, neste caso talvez o processo de remoção com -r não seja 100% efetivo, a remoção com esta opção limita-se a aplicação selecionada, no exemplo a acima seria o binário do htop, caso seja necessário garantir a completa remoção do pacote e de suas dependências de instalação utilize a opção “-P” ( --purge ):

```sh
dpkg -P htop
dpkg -l | grep htop
```
---

### Gerenciamento de pacotes com APT:

O gerenciamento avançado de pacotes em distribuições debian e derivadas utiliza um utilitário de linha de comando chamado “apt”, sua função é executar os mesmos processos de gerenciamento de pacotes do dpkg ( Na verdade rodando o próprio dpkg em suas execuções ) porém com um bônus: o Gerenciamento de repositórios.

Distribuições GNU/Linux de uso comercial costumam utilizar repositórios para facilitar o processo de centralização, validação e instalação de pacotes, fazendo um analogia simples cada repositório se comporta como um hub, um centralizador de pacotes a serem baixados, o mesmo coneito aplicado no uso da Apple Store e da Google Play por exemplo.

Exemplo: [http://br.archive.ubuntu.com/ubuntu/](http://br.archive.ubuntu.com/ubuntu/)

Para facilitar o entendimento deste processo execute o comando a seguir:

```sh
apt-get update
```

O comando executado é responsável pelo processo de atualização da lista de repositórios disponíveis para instalação de pacotes, ao executar este comando você reconstruiu o cache com a relação de pacotes e versões disponíveis para instalação;

Vamos a uma instalação via apt:

```sh
apt-get install cmatrix
cmatrix
```

> Verifique que o mesmo binário utilizado anteriormente foi instalado, porém sem o download prévio do arquivo .deb.

---

#### O processo de resolução de dependências:

Uma vez que o apt utiliza repositórios como o do exemplo acima como base pára instalação de pacotes ele possui a vantagem de conseguir baixar tanto pacotes quanto dependências de instalação, logo além da função de download automático de pacotes, o apt também acumula a função de resolver de dependências, o que significa que se o pacote A a ser instalado necessita do pacote B para funcionar, a execução do comando de instalação verificará esta dependência e deverá procurar o pacote B nos repositórios e executar sua instalação para então instalar o pacote A, este tipo de processo torna o apt o método mais fácil parta instalação e manipulação de pacotes.

Você pode verificar as dependências de um pacote utilizando o comando apt-cache:

```sh
apt-cache show htop 
apt-get install htop
```

Remoção de pacotes instalados poderão ser feitas com o comando apt-get remove:

```sh
apt-get remove cmatrix
```

#### Outras opções uteis do “apt”:

Ainda sobre o processo de remoção de pacotes, utilizando o apt também possuímos a opção ***--purge*** de apenas remover ou expurgar um pacote garantindo a remoção de todas as suas dependências:

```sh
apt-get remove --purge htop
```

Uma vez que o sistema apt utiliza uma lista de repositórios no processo de instalação de pacotes é possível executar consultas nessa lista com a função search do comando apt-cache e exibir informações sobre pacotes ( mesmo pacotes não instalados ) com a função show:


Localize o pacote traceroute:

```sh
apt-cache search “tracer” 
apt-cache show traceroute
```

Em seguida execute a instalação:

```sh
apt-get install traceroute
```

Atualização em massa de pacotes podem ser executadas utilizando a função upgrade:

```sh
apt-get upgrade
```

Para executar a instalação com base em reposítorios o apt executa  o download de todos os pacotes a serem instalados  para só então executar os gatilhos de instalação, estes pacotes são alocados no diretório de cache da aplicação:

```sh
ls /var/cache/apt/archives
du -hs /var/cache/apt/archives
```

Podemos limpar este repositório utilizando o comando abaixo:

```sh
apt-get clean
ls /var/cache/apt/archives

du -hs /var/cache/apt/archives
```

É possível executar o download de um pacote e suas dependências sem executar a instalação  utilizando a opção ***--download-only***:

```sh
apt-get install rar unrar –download-only
```

Verifique se os pacotes entraram no cache:

```sh
ls /var/cache/apt/archives

cd /var/cache/apt/archives
dpkg -i *.deb
```

> No exemplo acima os pacotes rar e unrar foram baixados porém sem execução do processo de instalação, sendo arquivos .deb poderemos executar a instalação tanto com apt quanto com dpkg -l

---

#### Verificando pacotes corrompidos:

O comando apt-get check pode ser usado para verificar arquivos corrompidos no S.O.:

```sh
apt-get check
```

Para executar um processo de correção de dependências utilize o comando abaixo:

```sh
apt-get -f install
```

---

#### O arquivo /etc/apt/sources.list:

O arquivo ***/etc/apt/sources.list*** é responsável pelas definições sobre quais repositórios serão utilizados pelo apt no processo de resolução de download de pacotes, além deste arquivo definições sobre repositórios a serem utilizados poderão ser alocadas dentro do diretório ***/etc/apt/sources.list.d*** em arquivos de configuração com a extensão ***.list***;

```sh
cat /etc/apt/sources.list
ls  /etc/apt/sources.list.d
```

---

#### Estrutura das entradas de repositórios:

- ***deb http://br.archive.ubuntu.com/ubuntu/ trusty main restricted***
- ***deb-src http://br.archive.ubuntu.com/ubuntu/ trusty main restricted***

- ***deb/deb-src:*** Essas duas linhas definem a URL retivas um mesmo repositório sendo que a primeira é utilizada em processos de instalação de pacotes, enquanto a segunda é utilizada em processo de download para compilação manual, para a maioria das necessidades de administração apenas a primeira linha é mandatária;

- ***http://br.archive.ubuntu.com/ubuntu/:*** Definição da URL  do repositório usado pelo apt, podem ser utilizados diversos repositórios como é o caso no arquivo que acessamos anteriormente, por padrão o apt sempre procurará pela versão mais nova de um pacote a ser instalado.

- ***trusty:*** Local onde serão procurados arquivos para atualização, neste campo geralmente é utilizado o nome de sua distribuição (trusty, xenial) padrão usado pelo ubuntu ou sua classificação (stable, testing ou unstable) padrão usado pelo debian.

- O padrão unstable é usado somente para desenvolvedores, máquinas de testes e QA para validação de pacotes em sua versão mais recente, sempre evite o uso em produção de pacotes unstable.

- ***main restricted:*** Representa as sessões de pacotes que serão consultadas, exatamente na ordem em que aparecem na linha de configuração.

---

#### Personalizando o seu sources.list:

Existem algumas fontes na internet a partir das quais é fácil gerar repositórios confiaveis, sempre verifique as URL de origem apontadas e use preferencialmente repositórios oficiais, no caso no Ubuntu esse [LINK](https://repogen.simplylinux.ch/) apresenta um ótimo recurso para geração de repositórios.

[[images/repogen.png]]
