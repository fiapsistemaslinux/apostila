##### Fiap - Soluções em Redes para ambientes Linux
profhelder.pereira@fiap.com.br

![alt tag](https://github.com/fiapsistemaslinux/apostila/raw/master/images/nginx-001.png)

---

## Introdução ao NGINX

O NGINX é um servidor web desenvolvido em 2004 conceitualmente como uma alternativa ao Apache, a proposta do nginx é a otimização de recursos de Memória e CPU, o que permite um aumento na quantidade máxima de requisições suportadas simultaneamente, o projeto possui uma boa [documentação](https://nginx.org/en/docs/) online e tem sido uma ótima solução para entrega de conteúdo mirando alta performance além de outras utilidades como, por exemplo proxy reverso e balanceador de carga.

## Arquitetura

Ao executar o NGINX, ele cria um processo pai, esse processo atua como controlador e não recebe diretamente requisições, mas executa outras funções como a leitura do arquivo de configuração do serviço, Geração e gravação de logs, atualizações de configuração sem downtime e principalmente a criação e manutenção dos processos de worker esses sim responsáveis por lidar com as requisições;

A figura abaixo foi retirada do [artigo](http://www.aosabook.org/en/nginx.html) de Andrew Alexeev:

![alt tag](https://github.com/fiapsistemaslinux/apostila/raw/master/images/nginx-002.png)

> Na época do surgimento do NGINX o Apache utilizava o modelo de fork/threads (módulo pré-fork) para tratar requisições o que gerava maior consumo de memória e processamento. O NGINX veio com a proposta de usar uma quantidade pré-determinada de workers e o conceito de eventos com processamento assincrono e não bloquantes o que otimiza razoavelmente os recursos, hoje o Apache também já opera nesse layout (módulo worker);

---

# Proxy Reverso

Servidores web podem ser utilizados tanto para servir conteúdo respondendo diretamente a requisições quanto para encaminhamento de requisições para outras aplicações que neste caso atuam como backend, nestes casos dizemos que o servidor web está atuando como um ***Proxy Reverso*** pois o servidor fica exposto para a internet e encaminha as requisições para a camada de baixo, é o que ocorre por exemplo na maioria das implementações de aplicações usando tomcat ou jetty que são soluções utilizadas para execução de aplicações Java no formato CONHECIDO COMO "Java Virtual Machines", as famosas JVMs;

Plataformas como Apache ou Nginx podem atuar nessa função de Proxy Reverso sendo responsáveis por formar essa primeira camada de requisições, do ponto de vista de arquitetura o layout fica mais ou menos como no diagrama abaixo obtido a partir do artigo "Nginx Reverse Proxy for Scalability" publicado na página [webapplicationconsultant.com](https://webapplicationconsultant.com/scalability/nginx-reverse-proxy-for-scalability/);


![alt tag](https://github.com/fiapsistemaslinux/apostila/raw/master/images/nginx-003.png)

## Para que precisamos disso?

É verdade que do ponto de vista técnico um servidor de aplicação como o tomcat já se comunica usando a pilha TCP/IP e consegue lidar sozinho com requisições do tipo HTTP, então qual a vantagem em adicionar uma camada extra na sua arquitetura implementando um proxy reverso?

A resposta é que geralmente um servidor de aplicação não possui todos os mecanismos de proteção que servidores como o NGINX ou Apache possuem, isso mesmo se tratando de uma arquitetura mais robusta como a do Projeto JBoss*, na prática, a maioria dos servidores de aplicação assumem que haverá um proxy reverso responsável por lidar com as requisições e as questões relacionadas a desempenho e segurança.

Sendo assim a exposição direta de um servidor de aplicação a requisições externas pode e provavelmente irá gerar diversas falhas de segurança, isso sem falar nas questões relacionadas a desempenho.

Em seu Livro [Desconstruindo a web](http://desconstruindoaweb.com.br/), Willian Molinari da um ótimo exemplo relacionado a problemas de performance caso um servidor de aplicação fosse exposto diretamente a internet:

* *Servidor de aplicação de código fonte aberto baseado na plataforma JEE*

> "Um exemplo de problema que pode ser gerado por expor o servidor de aplicação diretamente na internet é o consumo do serviço sendo degradado devido a conexão iniciada por clientes "mais lentos" ou seja com menor performance na comunicação. Falando de forma simplificada esses clientes podem "segurar uma conexão" impedindo que o servidor continue o processamento e segurando o processo. Os clientes em redes de celular geralmente se comportam dessa forma devido à demora para entregar a resposta em uma rede com maior latência, neste tipo de cenário é necessário possuir um proxy reverso que consiga lidar com uma grande concorrência de I/O"

---

## Material de Referência:

Boa parte da explicação acima, refere-se a documentação oficial do nginx, outra parte a obra de Willian Molinari:

* [Livro: Desconstruindo a web, Autor Willian Molinari](http://desconstruindoaweb.com.br/)
* [Livro: The Performance of Open Source Applications](http://www.aosabook.org/en/nginx.html)
* [NGINX Documentation](https://nginx.org/en/docs/)

----

**Free Software, Hell Yeah!**
