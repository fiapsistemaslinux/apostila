##### Fiap - Soluções em Redes para ambientes Linux
profhelder.pereira@fiap.com.br

---
# Iptables

## Conceitos importantes:

É muito comum criarmos uma certa confusão sobre o termo iptables, este é o nome dado ao programa de linha de comando usado para configurar regras de filtragem de pacotes, tendo sido um recurso implementado a partir do Kernel Linux 2.4.


> No Livro "Linux, Dominando firewall iptables" Urubatan Neto traz um conceito muito importante ao começar seu segundo capitulo esclarecendo que as funções de filtragem de pacotes são agregadas a arquitetura do kernel Linux, ou seja, diferente da maioria dos produtos aqui, o Firewall é um recurso nativo do sistema operacional, o que cria uma vantagem considerável sobre outras soluções do genero e torna o linux o core de grande parte das soluções implementadas no mercado.

### Sobre o protocolo TCP:

Falando da meneira genérica e simplificada no protocolo TCP/IP os dados são transmitidos pela internet agrupados em pacotes, esses pacotes podem conter até 1460 bytes de dados. Além dos dados, 40 bytes adicionais vão junto no pacote. Nesses 40 bytes algumas informações úteis a esta aula podem ser encontradas:

- IP de origem
- IP de destino
- Porta de origem
- Porta de destino
- Códigos de verificação
- Número do pacote

Os códigos de verificação servem para garantir a integridade dos dados que estão sendo trafegados na rede. A função básica do IP é cuidar do endereçamento e entrega de pacotes. A função básica do TCP é fazer verificações de erros e numeração de portas. Logo os dados tendem a ser transmitidos de forma quebrada, em pacotes menores e não ordenados, sendo executada a remontagem no destino.

### Sobre as portas:

Existem 65.536 portas TCP e UDP. Elas são numeradas de 0 e 65.535. As portas baixas estão na faixa entre 0 a 1023. Elas estão reservadas ao uso de serviços conhecidos e mapeados, como por exemplo: http, ftp, ssh, telnet, smtp, NFS e etc.
Qualquer porta na faixa acima de 1023 é considerada uma porta alta, sendo utilizada no trafego de pacotes especificos de serviços (o serviço de monitoramento zabbix por exemplo utiliza as portas 10000 e 10001 em sua configuração padrão).

Para revisar quais portas são relacionadas a quais serviços verifique o arquivo de referencia services:

```sh
# cat /etc/services
```

---

## Começando pelas Tabelas

Já sabemos que sistemas linux controlam nativamente o fluxo de dados que passa pelo kernel e que o iptables em si é uma ferramenta para filtragem destes dados, os chamados pacotes, no meio deste caminho tem mais um item importante, o NETFILTER, criado por Marc Bouncher, James Morris, Harald Welte e Rusty Russel o netfilter é base de dados que categoriza e armazena informações sobre os fluxos, logo o iptables utiliza o Netfilter para armazenar os fluxos de dados dividindo os em categorias.

Estruturalmente o NETFILTER é dividido em trẽs categorias: **filter, nat e mangle** e são a essas categorias que damos o nome de **TABELAS**, cada tabela possui uma finalidade especifica e conjuntos especificos de regras criados para cumprir essa finalidade.

O comando iptables exibe quando executado sem qualquer parametro exibe informações sobre a tabela filter:

```sh
# iptables -L
```

Já para visualizar outra tabela utilizamos o parâmetro **"-t"** seguido do nome da tabela:

```sh
# iptables -t nat -L
# iptables -t mangle -L
```

> Para facilitar a explicação e simplificar as primeiras aulas utilizaremos sempre o parâmetro **"-t"** mesmo para a tabela filter.

## CHAINS

Cada uma das tabelas listadas acima é composta por fluxos que por sua vez são categorizados ( entreda, saida, redirecionamento e etc), considere a tabela filter por exemplo, ela possui três categorias de fluxos: INPUT, OUTPUT e FORWARD esse fluxos por sua vez, recebem o nome de CHAINS, é sobre as chains que aplicamos as regras com iptables.

Abaixo uma descrição resumida de cada uma das tabelas e suas respectivas CHAINS:

###Tabela FILTER:###

Conjunto de regras utilizadas para filtro de pacotes, sendo a tabela detentora dos três fluxos ( CHAINS ) citados acima: 

```sh
# iptables -t filter -L
```

- **INPUT:** Tratamento de tudo que entra pelo kernel;
- **OUTPUT:** Tratamento de tudo que sai pelo kernel;
- **FORWARD:** Tratamento de pacotes que chegam ao kernel  mas devem ser redirecionados a outro kernel ou a outra interface de rede dentro do mesmo kernel;

### Tabela NAT:

Na tabela NAT temos o conjunto de regras cuja função é executar o NAT (Network Address Translation) sobre os pacotes que passam pelo kernel.

```sh
# iptables -t nat -L
```

- **PREROUTING:** Chain utilizada para alterações de pacotes antes de seu roteamento;
- **OUTPUT:** Tratamento de pacotes que serão emitidos pelo kernel;
- **POSTROUTING:** Natuaralmente utilizada quando necessário a alteração de pacotes após seu roteamento;

### Tabela MANGLE:

Finalmente na mangle encontraremos regras específicas para funções complexas de tratamento de pacotes, por exemplo, aplicação de TOS.

```sh
# iptables -t mangle -L
```

- **PREROUTING:** Modificação de pacotes antes de seu roteamento;
- **OUTPUT:** Altera pacotes gerados localmente pelo kernel antes que sejam emitidos;

> A tradução literal do termo CHAIN seria "corrente", logo, cada tabela teria um conjunto de correntes, e para cada corrente, cada elo corresponderia a uma regra.

Durante nossos testes existem situações em que é mais prático visualizar apenas uma CHAIN, principalmente quando temos elevado numero de regras nas tabelas, para isso utilize a sintaxe abaixo:

```sh
# iptables -t filter -L INPUT
# iptables -t nat -L  PREROUTING
```

---

## Politica de firewall

Para cada uma das chain utilizadas no iptables existe uma POLICY, a policy define qual o padrão de comportamento de uma chain, ou seja, define se, por padrão a chain será PERMISSIVA, uma política do tipo **Accept**, ou restritiva, com uma política do tipo **Drop**.

O parâmetro "-P" do iptables permite definir essa policy.


## Praticando iptables: 

Vamos começar pela prova de conceito sobre as politicas de firewall citadas a pouco, 

 1 - Primeiro faça um teste com base na policy padrão, geralmente ela é permissiva:

```sh
# iptables -t filter -S
# ping 127.0.0.1
```

 2 - Em seguida modifique a policy da chain de entrada para o padrão restritivo e repita o teste:

```sh
# iptables -t filter -P INPUT DROP
# iptables -t filter -S
# ping 127.0.0.1
```

> Verifique que como a politica padrão de entrada passou a ser o Drop de pacotes não podemos mais testar conectividade nem mesmo localmente pois não existe nenhuma regra criada para liberar a comunicação.
> Ao apostar em uma política restitiva de entrada automaticamente temos a necessidade de criar regras especificas prevendo quais os tipos de pacotes que poderão navegar na rede, neste, tudo que não for expressamente proibido será negado.


 3 - Tendo funcionado o bloqueio anteior vamos a liberção de acesso:

```sh
# iptables -t filter -A INPUT -s 0/0 -d 127.0.0.1 -j ACCEPT
# ping 127.0.0.1
# iptables -t filter -S
# iptables -t filter -nL
```

> No exemplo acima criamos uma regra de liberação dentro da chain INPUT da tabela filter, um conceito interessante útil para se aprender iptables ( conceito aprendido com a Gabriela Dias da 4Linux ) é que se você consegue ler uma regra por extenso como se fosse um texto então você realmente a entende, se aplicarmos esse lógica a regra anteior teriamos algo mais ou menos assim:

> **Tudo que entrar na tabela filter, de qualquer origem com destino ao endereço 127.0.0.1 será aceito**

 4 - Para comprovar a regra descrita acima teste o ping para algum outro endereço que não seja o 127.0.0.1:

```sh
# ping 192.168.1.1
# ping 8.8.8.8
```

 5 - E se quisessemos liberar a entrada e pacotes para qualquer endereço?

```sh
# iptables -t filter -A INPUT -s 0/0 -d 0/0 -j ACCEPT
# iptables -t filter -nL
# ping 8.8.8.8
# ping 127.0.0.1
```

 6 - Já que liberamos entrada total de pacotes a regra anterior já poderia ser removida, para isso primeiro identifique seu número de ordem dentro do iptables:

```sh
# iptables -t filter -nL --line-numbers
# iptables -t filter -D INPUT 1
# iptables -t filter -nL
```


### DUMP de regras criadas "Memory card do iptables"

Ao construir as regras dos exemplos acima estavamos fazendo alterações diretas no netfilter via FrontEnd, essas alterações são gravadas em memória, logo em um processo de reboot seriam todas perdidas.

Existe um comando específico para salvar e outro para recuperar as regras salvas:

 1 - Salve as regras criadas no exemplo anterior para testarmos o recurso:

```sh
# iptables-save > /tmp/firewall
# cat /tmp/firewall
```

 2 - Em seguida remova as regras, altere a policy aplicada:

```sh
# iptables -t filter -P INPUT ACCEPT
# iptables -t filter -F INPUT
# iptables -t filter -S
```
 
> O parâmetro -F utilizado acima limpa todas as regras de uma chain, portanto cuidado com sua execução em um ambiente em produção, alias se não especificarmos a chain limparemos todas as regras da tabela filter inteira.

 3 - Teste o processo de restore das regras salvas:

```sh
# iptables-restore < /tmp/firewall
# iptables -t filter -S
```

## Tabelas de referência:

### Parâmetros para manipulação com iptables:

| Parâmetro | Valor por extenso | Descrição da regra:		      					| 
|---------|---------------------|-----------------------------------------------------------------------|
| -P	  | --policy 		| Estabelece a politica de acesso a uma CHAIN				|
| -t	  | --table  		| Seleciona uma tabela                        				|
| -A	  | --append 		| Adiciona uma regra no **final** da sequência de regras de uma CHAIN	|
| -I	  | --insert 		| Adiciona uma regra no **inicio** da sequência de regras de uma CHAIN	|
| -N	  | --new-chain		| Cria uma nova chain							|
| -D	  | --delete		| Deleta uma regra							|
| -f	  | --flush		| Elimina todas as regras de uma chain ou de uma tabela			|
| -s	  | --souce		| Especifica qual o endereço de origem de um pacote			|
| -d	  | --destination	| Especifica qual o endereço de destino de um pacote			|
| -p	  | --protocol		| Seleciona o protocolo a ser utilizado tcp, udp ou icmp		|
| -i	  | --in-interface	| Especifica qual a interface a ser manipulada na entrada		|
| -o	  | --out-interface	| Especifica qual a interface a ser manipulada na saida			|
| --dport | --destination-port	| Define qual a porta de destino					|
| --dport | --source-port	| Define qual a porta de entrada					|


### Alvos para manipulação com o iptables:

| Alvo	  | Descrição do alvo:		      						| 
|---------|-----------------------------------------------------------------------------|
| -ACCEPT | O pacote é aceito								|
| -REJECT | O pacote é rejeitado                     					|
| -DROP	  | o pacote é simplesmente "dropado" existe uma negação mas sem retorno	|
| -LOG	  | Cria uma saída em LOG para uma regra de iptables, usado para depuração	|


## Material de Referência sobre a iptables e firewallD:

* [Página do projeto iptables](https://www.netfilter.org/projects/iptables/)

----

**Free Software, Hell Yeah!**
