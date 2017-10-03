![alt tag](https://raw.githubusercontent.com/wiki/helcorin/fiapLinux/images/backup-desc.png)

---

## Sintronizando pastas com RSYNC

O Rsync é um recurso amplamente utilizado em sistemas linux em processos de transferencia de arquivos ou sincronização de pastas, suas funções vão um puuco além do scp sendo implamentadas em scripts de backup remoto por exemplo.

A sintaxe basica do rsync é simular a que já utilzamos com o recurso scp do ssh:

**rsync  <opções>  <origem>  <destino>**

Para começar faça a instalação do rsysnc:

```sh
yum install rsysnc
```

> Na familia Debian utilize o apt com o mesmo pacote "rsync"

Sincronizando duas pastas localmente:

```sh
rsync -ahvz /etc /tmp/
ls /tmp/
```

Forçe algumas alterações dentro da estrutura do /etc adicionando um novo usuário:

```sh
useradd webmaster
```

Observe que se executar novamente o rsysnc com o mesmo destino o comando atuará sincronizando os arquivos APENAS alterados ao invés de executar uma nova cópia completa:

```sh
rsync -ahvz /etc /tmp/
```

Outra pssobilidade é utilizar o rsync para sincronizar pastas remotamente:

```sh
rsync -ahvz /var/log/ suporte@192.168.X.X:/tmp/log
```

Opções utilizadas com o rsysnc:

* -v, --verbose
* -r, --recursive             recurse into directories
* -z, --compress              compress file data during the transfer
* -h, --human-readable        output numbers in a human-readable format
* -a, --archive               archive mode; equals -rlptgoD (no -H,-A,-X)

Por padrão a transferência de arquivos NÃO utiliza o ssh, ou seja, o rsysnc não garante a criptografia no processo de transferência a não ser que a opção “-e” seja especificada:

```sh
rm -rf /tmp/*
rsync -ahvze  ssh suporte@192.168.X.X:/etc /tmp
```

> Neste exemplo utilizamos o rsysnc para “puxar” o conteudo da pasta /etc do servidor remoto;

---

## Material de Referência:

Os exemplos utilizados acima foram baseados em um artigo publicado  no tecmint, segue um link para o artigo completo com 10 exemplos úteis de como atuar com o rsysnc:

* [10 Practical Examples of Rsync Command in Linux](https://www.tecmint.com/rsync-local-remote-file-synchronization-commands/);

---

**Free Software, Hell Yeah!**
