# Arquitetura de um servidor de conteúdo usando Opensource

**Objetivo:**

Desenvolver o projeto de implementação para uma arquitetura que suporte a implementação de uma solução LAMP, ou seja: Linux + Apache (ou Nginx), + MySQL (ou PostgreSQL) + PHP

---

## Formato:##

Os alunos devem trabalhar em duplas e definir nesta primeira etapa o projeto base a ser implementado em aula, considerar os seguinte fatores:

1. O projeto refere-se a implementação de uma plataforma de páginas colaborativa chamada MediaWiki cuja documentação pode ser obtida [Neste Endereço](https://www.mediawiki.org/wiki/MediaWiki);
2. A plataforma será hospedada em uma distirbuição Linux de sua escolha e possuirá uma base de dados (MySQL ou PostgreSQL);
3. A quantidade de servidores ou containers utilizado na implementação fica a cargo da dupla;
4. Definir com base nos itens anteriores o modelo de arquitetura que utilizaram para este projeto, criar um documento com a especificação técnica do projeto de acordo com o layout descrito abaixo;
5. Será necessário que a solução implementada possua um Firewall de Host baseado em iptables para liberação de acesso apenas a portas necessárias para administrar a aplicação (80 e/ou 443);

## Layout da Documentação:

### Corpo da Documentação:
Sua documentação deverá conter no mínimo as seguintes informações:

* Sistema Operacional Linux Utilizado;
* Solução de servidor de contepudo utilizada (Apache ou Nginx);
* Solução de banco de dados utilizado (MySQL ou PostgreSQL);

### Itens opcionais:
* Solução de Firewall utilizada nas instnacias responsáveis por servir a aplicação (Iptables, FirewallD etc);
* Configuração de HTTPS e criptografia no webserver responsável pela aplicação;

### Questões que devem ser respondidas:

Além das informações requeridas garantir que na documentação do projeto os seguintes itens sejam respondidos:

* Quais as motivações que levaram a escolha desta distribuição Linux? (Justificar com base em critérios como a comunidade, modelo de lançamento de releases, caracteristicas internas como o gerenciamneto de pacotes etc);
* Qual o modelo de arquitetura escolhido? (Considerar se a arquitetura utilizará apenas um servidor ou mais, haverá segregação entre o frontend e o backend com a base de dados?)
* Qual a solução de banco de dados? (Verificar entre o postgreSQL e o MySQL qual se enquadra melhor ao seu projeto);
