# Uma Introdução a filosofia opensource:

***Porque Software Livre?***

A filosofia do Software Livre antecede o software proprietário, ela permitiu, por exemplo, que a Internet se desenvolvesse e alcançasse a forma como a conhecemos hoje. Como um novo usuário de Software Livre é preciso compreender um pouco mais sobre essa ideologia e como ela promoveu o surgimento das várias distribuições.

Em 1991, um jovem finlandês chamado Linus Torvalds disponibilizou para o mundo a primeira versão do Linux, um kernel Unix-like1. A partir desse ponto, foi possível unir o kernel Linux com os softwares GNU, originando o sistema operacional Linux. O mundo GNU/Linux não é apenas um conjunto de programas. Ele traz consigo essa filosofia de Mundo Livre e colaborativo, na qual as pessoas podem utilizar softwares irrestritamente, acima de tudo, aprender com eles, uma vez que seu código fonte deve ser disponível a todos que queiram melhorá-lo ou estuda-lo.

Para que esse mundo continue livre, Richard Stallman fundou a [FSF](https://www.fsf.org/pt-br) - "Free Software Foundation", que criou e mantém a licença "GNU GPL - GNU General Public License". Esta licença basicamente define que o "Software" deve respeitar quatro princípios básicos:

1. Liberdade para rodar o programa para quaisquer propósitos;

2. Liberdade para estudar como o programa trabalha e adaptá-lo às suas necessidades. Ter acesso ao código fonte é essencial para isso;

3. Liberdade de redistribuir cópias; de forma NÃO COMERCIALIZÁVEL!

4. Liberdade para melhorar o programa e disponibilizar as melhorias para o público, de forma que toda a comunidade possa se beneficiar.

Após a criação dessa licença, várias outras, foram criadas com o mesmo objetivo de defender a liberdade do conhecimento e informação, como por exemplo, a [GFDL-GNU](https://www.gnu.org/licenses/fdl-1.3.html) “Free Documentation Licence”, [OPL](http://www.opencontent.org/openpub/) – “Open Publication License”, [CC](http://creativecommons.org/about/licenses) – “Creative Commons” e [BSD](http://www.freebsd.org/copyright/license.html) – “Berkeley Software Distribution”.

Você pode consultar uma relação mais exata dessas licenças bem como sua discriminação no site [opensource.org](https://opensource.org/licenses);

> ***Sobre o cara que garante que meu emprego exista:*** Linus Benedict Torvalds nascido em 28 de Dezembro de 1969 é o criador do Linux, núcleo do sistema operacional GNU/Linux, Estudou na Universidade de Helsinki. Vive atualmente em Santa Clara, na Califórnia, Atualmente trabalha na Open Source Development Labs (OSDL).

---
	
**O que exatamente é OpenSource?**

Segundo o próprio site opensource.org, OpenSource ou em português software livre é uma definição criada para categoriar qualquer software que possa ser utilizado livremente, alterado e compartilhado por qualquer pessoa. Este tipo de software é distribuído sob licenças que estejam em conformidade com a definição de Open Source, ou seja, que respeitem e garantam a gratuidade e a liberdade deste modelo. Os defensores da proposta Open Source sustentam que não se trata de algo anticapitalista ou anarquista, mas de uma alternativa ao modelo de negócio para a indústria de software.
	
**Quais as vantagens de se trabalhar com software livre?**

Apesar de questões de economia relacionadas com as licenças existentes em softwares proprietários, a principal questão sobre software livre é a possibilidade de adaptação e customização que deriva destes sistemas, um sistema operacional direcionado a execução de um SGBD Postgres por exemplo pode ser otimizado em relação a sua performance e adaptado as necessidades de seus adminsitradores, o que  em sistemas proprietários demandaria certa burocracia, por esse motivo o desempenho e a confiabilidade de qualquer implementação  de ferramentas opensource dependerá essencialmente das habilidades dos administradores e programadores envolvidos. 
	
**Por que existem tantas distribuições GNU/Linux?**

Justamente porque se você não se identifica com nenhuma delas, você é livre para fazer a sua própria. Por exemplo, em 1993, um rapaz chamado Patrick Volkerding, juntou o kernel e vários outros aplicativos em uma distribuição chamada Slackware, que foi a primeira versão de Linux a ser distribuída em CD.

Atualmente existem centenas de distribuições, algumas mais famosas que outras. Em sua maioria, as distribuições são mantidas por grandes comunidades de colaboradores, entretanto, há outras que são mantidas por empresas. Dessa forma, podemos dividir as distros em duas categorias básicas: Livres ou Corporativas.

## Distribuições Livres:

As Distribuições Linux em geral são classificadas como livres quando mantidas por comunidades de colaboradores sem fins lucrativos, ou seja, grupos de pessoas adeptas a filosofia do software livre, e que objetivam disponibilizar um sistema bom para os usuários e compartilhar conhecimento;

São exemplos de distribuições livres:

- [Debian](https://www.debian.org/index.pt.html)
- [Slackware](http://www.slackware.com/)
- [Gentoo](https://www.gentoo.org/)
- [Mint](https://www.linuxmint.com/)
- [Centos](https://www.centos.org)
- [Alpine](https://www.alpinelinux.org/)
- [ArchLinux](https://www.archlinux.org/)

## Distribuiçes Coorporativas:

Já as distribuições Coorporativas são mantidas por empresas que criam e controlam as versões obtendo o seu lucro através da venda de suporte ao seu sistema já que respeitando as liberdades criadas pela FSF **não é possível vender as distros**; 

Citando alguns exemplos:

- [Suse](https://www.suse.com/pt-br/)
- [RedHat](https://www.redhat.com/pt-br)
- [Fedora](https://getfedora.org/pt_BR/)
- [Ubuntu](https://www.ubuntu.com/)
- [CoreOS](https://coreos.com/)

> Vale ressaltar que o produto vendido pelas empresas que comercializam sistemas GNU/Linux, é na verdade, os serviços relacionados ao sistema operacional, como suporte técnico, garantias e treinamentos, ou seja, a “expertise” do sistema. Tecnicamente, não há produto algum sendo vendido, apenas os serviços relacionados aos softwares agregados na distribuição;

## Distribuições Provenientes:

Outra maneira interessante de classificação de distros relaciona-se a maneira como são criadas, distribuições linux podem ser desenvolvidas do zero, ou seja, utilizando como base  apenas um kernel Linux e alguma base de programas GNU, nesse método a vantagem é o maior nível de customização e o desenvolvimento voltada para demandas especificas, Como exemplos deste formato temos as distros Debian, RedHat, Gentoo e Slackware.

Já as chamadas distros provenientes aproveitam ferramentas e bases já desenvolvidas por outras distribuições, o maior exemplo de uma distribuição baseada que faz grande sucesso atualmente é o Ubuntu, baseado na distro Debian, além dele também podemos citar o Kubuntu baseado na distro Ubuntu e consequentemente no Debian e o Kali uma distro voltada para segurança baseada no Xubuntu e no Debian;

## Qual versão de sistema Linux utilizar?

Pergunte a um administrador de sistemas qual a melhor versão de Linux a ser utilizada para a construção de um servidor de aplicação e você obterá uma resposta, encontre outros nove administradores, faça a mesma pergunta e pode ser que obtenha outras 9 respostas diferentes; Existem centenas de versões de Linux em uso no mundo uma caracteristica natural do formato OpenSource discursido acima, Para começar você pode ter uma noção melhor da quantidade de distros disponíveis através do [Distrowatch](https://distrowatch.com), funciona como uma espécie de catálogo relacionando projetos Linux Ativos. 

> Dentro desse material utilizaremos basicamente três plataformas: [Ubuntu](https://www.ubuntu.com/download) versão 16.04, [CentOS](https://www.centos.org/download/) em sua sétima versão, uma solução cuja arquitetura reflete perfeitamente um sistema Red Hat.

---

## O Kernel

O kernel é o componente central do sistema. É tão importante que muitas vezes é confundido com o sistema em sua totalidade, ou seja, apesar de o termo Linux designar apenas o componente central – o kernel –, ele é normalmente utilizado para designar todo o sistema, que é composto por muitos outros programas.

Por isso, muitos desenvolvedores e personagens importantes do mundo do Software Livre preferem nomear o sistema como GNU/Linux, dado que a maior parte dos programas que funcionam em conjunto com o kernel Linux fazem parte do [Projeto GNU](https://www.gnu.org/), cujo propósito é manter um ambiente de desenvolvimento e ferramentas o mais próximo possível de seus similares do Unix, porém obedecendo ao modelo de desenvolvimento aberto.

O termo código aberto refere-se a um modelo de desenvolvimento de programas de computador no qual o acesso ao código fonte é liberado para consulta, alteração e redistribuição. Isso faz com que um número muito grande de programadores possa analisar e contribuir para o desenvolvimento de uma ferramenta ou sistema, na medida em que podem alterá-lo para satisfazer suas próprias necessidades. Alterações feitas no programa original podem ser tornadas públicas ou enviadas à pessoa ou equipe responsável, que analisará a qualidade da alteração e a incorporará ao produto. Linus Torvalds, o criador e atual administrador do kernel, adotou o modelo de desenvolvimento e as licenças GNU para o Linux.

O kernel Linux é um desses componentes que juntos formam o sistema operacional. O papel do kernel é identificar e controlar a comunicação com o hardware, administrar os processos em execução e a comunicação de rede, entre outras atividades relacionadas.

> A palavra GNU é um acrônimo recursivo de GNU's not Unix. Trata-se, de um grupo de desenvolvedores fundado em 1984 por seu idealizador, Richard Stallman, com o intuito de criar um sistema operacional baseado no formato Unix, mas desprovido de amarras e travas ao seu uso. (Uma vez que o unix é ligado a corporações como a gigante de telecomunicações americana AT&T).

---

## Estrutura base de um sistema Linux

Sistemas Linux possuem uma organização que define qual a composição de diretórios de da estrutura base de uma distribuição bem como qual a nomenclatura correta para estes diretórios, este sistema é chamado de FHS “File Hierarchy Standard” a estrutura proposta garante questões essenciais a evolução do sistema como por exemplo a compatibilidade entre diferentes plataformas, a estrutura FHS possui os seguintes diretórios:

[[images/Linux-FHS.jpg]]

---

## Command Line, Primeiros Passos:

Embora vagamente parecidos, do ponto de vista de arquitetura existem grandes diferenças entre um terminal Linux e o prompt de comandos do DOS, sistemas Linux utilizam o interpretador de comandos para fornecer um ambiente para execução de tarefas, esse ambiente é responsável por assimilar os comandos enviados ao sistema e traduizir isso em “linguagem de máquina” para o sistema operacional esse interpretador de comandos carrega o nome de SHELL.


### Níveis de usuários:

Para inicio de estudos  esta informação é muito importante uma vez que, cada tipo de usuário possui suas limitações existindo duas possibilidades:

***Usuário comum:***: Qualquer usuário do sistema que não seja o administrador do sistema, ( Geralmente identificado como "root" ) ou que não tenha poderes administrativos concedidos, na maioria dos interpretadores de comandos o padrão é que a "Shell" de um usuário comum seja identificado com "$" cifrão;

***Super usuário:***: Popularmente conhecido como "root",  usuário "root" é o administrador do sistema, e seu diretório (pasta) padrão é o "/root", diferente dos demais usuários que possuem sua pasta padrão no diretório /home.

O "Shell" de um usuário "root" se diferencia do "Shell" de um usuário comum, pois antes do cursor, ele é identificado com "#" ( jogo-da-velha ).

---

## Material de Referência e Recomendações:

Documentário da TV Finlandesa de 2001 sobre o Sistema Operacional GNU/Linux:
 - [Documentário The Code](https://www.youtube.com/watch?v=qtXYXLeeU5s)

Entrevista do Richard Stellman ao Tecmundo: 
 - [Tecmundo: "Conversamos com Richard Stallman"](https://www.tecmundo.com.br/software-livre/34146-conversamos-com-richard-stallman-o-guru-do-software-livre.htm);

----

**Free Software, Hell Yeah!**
