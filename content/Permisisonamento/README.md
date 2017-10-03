##### Fiap - Soluções em Redes para ambientes Linux
profhelder.pereira@fiap.com.br

![alt tag](https://raw.githubusercontent.com/wiki/helcorin/fiapLinux/images/perm-desc.png)

---

## Permissões Especiais:

Além do permissionamento padrão utilizando chmod existem três bits de permissionamento especial que podem ser utilizados ( E já são utilizados ) pelo sistema em situações especificas e configurações especificas, o primeiro deles é o SUID:

---

### SUID "Set Owner User ID":

Bit que pode ser aplicado no permissionamento de arquivos, sua função é **"Definir que o arquivo seja executado utilizando permissões de seu Dono, o proprietário do arquivo definido em sua criação ou via chown"**

> Por padrão ao executarmos um programa será aplicado a ele as permissões de acesso do usuário que o executa, em geral utiliza-se o suid bit para mdificar essa regras fazendo com que um programa possa ser executado como root.

Exemplo, conside o binário passwd abaixo, verifique que este binário possui o SUID bit configurado, essa informação aparece no campo "s" presente dentro do grupo de permissões de usuário ***-rwsr-xr-x***, por isso "rws" ao invés do já conhecido "rwx".

```sh
# ls -l $(which passwd)
```

Faça uma copia deste binario para não comprometermos o arquivo original:

```sh
# cp -a $(which passwd) /tmp/
# ls -l /tmp/passwd
```

Remova a permissão especial suid usando o chmod:

```sh
# chmod u-s /tmp/passwd
# ls -l /tmp/passwd
``` 

Para este teste faremos o seguinte: Primeiro criaremos um usuário chamado "luke":

```sh
# useradd luke -s /bin/bash -m -d /home/luke
# echo -e "123456\n123456" | passwd luke     # Modifiquei a senha do luke para 123456
# su - luke
# whoami
``` 

Em seguida tentaremos modificar a senha deste usuário utilizando nossa versão do passwd que não possui o suid bit configurado:

```sh
# /tmp/passwd

Changing password for luke.
(current) UNIX password: 
Enter new UNIX password: 
Retype new UNIX password: 
passwd: Authentication token manipulation error
passwd: password unchanged

```

> Verifique que utilizamos o mesmo binário utilizado ao executar o comando passwd, a diferença é que este não possui o suid bit configurado e que como o diretório "/tmp" não faz parte da path do sistema foi necessário definir o caminho absoluto ao executa-lo, Por isso rodamos como "/tmp/passwd".

Resultado obtido: 

Não foi possivel que o usuário modificasse sua própria senha, motivo: Para modificar sua senha é necessário executar uma alteração no arquivo /etc/passwd e uma inclusão do hash gerado no arquivo /etc/shadow, se verificar a permissão desses arquivos ficará fácil entender o problema:

```sh
# ls -l /etc/passwd
# ls -l /etc/shadow
``` 

Ambos os arquivos pertencem ao usuário root e não possuem permissão de escrita aberta por tanto não podem ser manipulados por outros usuários, o bit suid é o responsável por modificar esse comportamento, é a partir dele que o comando passwd mesmo executado por um usuário comum pode "escrever" alterações em arquivos de configuração que segundo o permissionamento do sistema só poderiam ser alterados pelo root.

Para seu ultimo teste adicione novamente a permissão especial ao arquivo ( Você precisará de um usuário avançado para isso ):

```sh
# su - root
# chmod u+s /tmp/passwd
```

Finalmente utilizando o usuário luke tente manipular sua própria senha:

```sh
# su - luke
# /tmp/passwd
```

> Neste segundo exemplo a modificação ocorrerá com sucesso, é comum bibliografias que definem a remoção do SUID bit como um processo de hardening, mas nem sempre isso é verdadeiro, no exemplo acima e em alguns outros casos o SUID bit pode ser importante para o sistema.

---

### SGID "Set Group ID":

A função da permissão SGID é um pouco mais simples que a permissão anterior, o SGID é utilizado em diretório para ajustar a permissão de diretório, forçando a herança de grupos na criação de sub-diretórios, ao definir o SGID bit sob um diretório arquivos criados dentro deste diretório pertenceram ao mesmo grupo do diretório.

Por padrão ao criar um diretório em sua permissão de grupo ele será atribuido ao seu usuário corrente conforme exemplo abaixo:

```sh
# mkdir /srv/skywalkers
# ls -l
```

Considere que o diretório acima será uma psta compartilhada para a familia skywalker:

```sh
# useradd leia -s /bin/bash -m -d /home/leia && echo -e "123456\n123456" | passwd leia
# groupadd skywalkers
# gpasswd -M luke,leia skywalkers
```

Para que ambos possam editar arquivos será utilizada uma permissão aberta para grupo skywalker e o luke passará a ser o dono da pasta:  

```sh
# chmod 770 /srv/skywalkers
# chgrp skylwalkers /srv/skywalkers
```

Eis o seu problema: Tente criar um diretório utilizando o usuário leia e verifique suas perissões:

```sh
# su - leia
# cd /srv/skywalkers
# mkdir republica
# ls -l
```

Além do problema das permissões, existe uma outra questão, o acesso a pasta republica para o Luke uma vez que a pasta pertence a leia:

```sh
# su - luke
# cd /srv/skywalkers
# ls -l
# touch republica/x-wing.txt
touch: cannot touch ‘republica/x-wing.txt’: Permission denied
```

> Consegue entender o problema acima? Apesar da permissão dada para a familia skywalkers os sub diretórios ainda estão herdando a permissão padrão de grupo baseada no grupo primario do usuário que o criou...

Configure o sgid bit sobre este diretório:

```sh
# su - root
# chmod g+s /srv/skywalkers
# ls -l /srv
```

Com o usuário leia volte ao diretório skywalkers e tente recriar o sub-diretório republica:

```sh
# su - leia
# cd /srv/skywalkers
# rm -r republica
# mkdir republica
# ls -l
```

Só pra fechar tente novamente com o usuário luke criar aquele arquivo sobre as x-wings:

```sh
# su - luke
# cd /srv/skywalkers
# ls -l
# touch republica/x-wing.txt
# ls -lR
```

> Só pra constar, outra solução possível seria utilizar o comando usermod para determinar que "skywalkers" é o grupo primário de ambos os usuários mas ai n;ao teria tanta graça e nem exemplo para uso de sgid, além disso a depender do umask configurado não haveriam mais segredos entre leia e luke mesmo em relação asuas respectivas HOME de usuários, Uma terceira abordagem válida porém mais complicada é utilizar ***access control lists*** no compartilhamento.

---

### STICKBIT "Append Only:

Assim como o SGID o Stick Bit tem seu uso mais frequentemente vinculado a configuração de permissão em diretórios, sua função é bem simples ***Impedir que outros usuários removam arquivos que não são donos*** ( Mesmo quando possuirem permissão especifica para isso dentro do diretório );

Como exemplo considere novamente o compartilhamento que criamos para a família skywalker:

```sh
# su - root
# mkdir /srv/skywalkers/publico
# chgrp nobody:skywalkers /srv/skywalkers/publico
# chmod 777 /srv/skywalkers/publico
# chmod +t /srv/skywalkers/publico
# ls -l /srv/skywalkers
```

> Acabamos de configurar o stick bit no arquivo x-wing.txt, teoriamente o usuário leia poderia remover este arquivo pois a permissão aplicada sobre o diretório skywaler é 770 dando completos poderes aos membros da familia, também utilizamos o usuário "nobody" para garantir que ninguémseja dono da pasta, o que influenciaria em nossos testes.

Crie dois diretórios usando o usuário luke na pasta público:

```sh
# su - luke
# mkdir /srv/skywalkers/publico/pasta-{1..2}
```

Tente renomear um destes arquivos utilizando o usuário leia:

```sh
# su - leia
# cd /srv/skywalkers/publico/
# rm -r pasta-1
```

> Um exemplo de diretório onde o sistema aplica essa permissão é o /tmp , todos os usuários devem ter acesso para que seus programas possam criar os arquivos temporários lá, mas nenhum pode apagar arquivos dos outros.

---

## Sobre as ACLS, "Access Control Lists":

As ACLS são recursos para controle de acessos de usuários e grupos sobre Linux File System, sua configuração é consideravelmente complexa e não deverá ser abordada durante o curso, mas você pode consultar informações sobre isso nos links recomendados abaixo:


Este artigo publicado por Benjamin Cane é um ótimo inicio para o uso de ACLS:

 * [Using Access Control Lists on Linux, Escrito por Benjamin Cane](http://bencane.com/2012/05/27/acl-using-access-control-lists-on-linux/);

Fora isso temos a documentação oficial da RedHat que tratará de forma mais técnica sobre o assunto:

 * [RedHat: ⁠Chapter 20. Access Control List](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Storage_Administration_Guide/ch-acls.html);

---

## Umask "Set File Mode Creation Mask":

Conforme descrito no inicio desta aula o calculo de umask refere-se a definição de permissões iniciais para o processo de criação de pastas e arquivos, sua sitaxe pode parecer complexa inicialmente mas é extremamente lógica, entendendo essa lógica domina-se a base para este cálculo.

Para este conteúdo utilizaremos o material online do Guia Foca Linux, [Capítulo 13.11 Umask](http://www.guiafoca.org/cgs/guia/intermediario/ch-perm.html#s-perm-umask); 

---

## Material de Referência e Recomendações:

A base para estudos sobre permissionamentos especiais foi extraida de publicação abaixo disponibilizada no slideshare, autoria de Fábio dos Reis da Bóson Treinamentos; 

* [Permissões Especiais](https://pt.slideshare.net/bosontreinamentos/permisses-especiais-suid-sgid-sticky-linux);

Ebook, Linux Command Line de William Shotts, Capitulo 11 – The Environment:

 * [The Linux Command Line, 11 – TThe Environment](http://linuxcommand.org/tlcl.php);


Guia Foca Linux, Capítulo 21 - Personalização do Sistema;

 * [Guia Foca Linux Online, Capítulo 11](http://www.guiafoca.org/cgs/guia/intermediario/ch-pers.html);

---

**Free Software, Hell Yeah!**