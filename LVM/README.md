##### Fiap - Soluções em Redes para ambientes Linux
profhelder.pereira@fiap.com.br

---
# LVM, conceito e configuração de volumes

## O que é LVM?

O termo LVM significa "Logical Volume Management" trata-se exatamente de um sistema de manipulação e gerencia de volumes lógicos, esses volumes representam uma alternativa a montagem manual de partições ( Abordada na aula sobre sistemas de arquivos ), sendo amplamente adotado por projetos como RedHat ou Ubuntu
 
## Qual a vantagem no uso de LVM?

O uso de LVM é indiscutivelmente vantajoso por se tratar de um modelo mais flexível que o modelo de particionamento padrão, em um modelo de particionamento simples utilizando a formatação e montagem direta e/ou via fstab o processo de redimensionamento de discos torna-se um pouco mais complicado envolvendo uso de aplicações como o gparted, ou seja, o uso de LVM substitui a necessidades de outras ferramentas no processo, na prática o LVM fará o mesmo que as ferramentas de gerenciamento de disco fariam só que de forma melhor e menos complicada.

## Conceitos sobre LVM:

Para começar precisamos entender três conceitos importantes sobre LVM:

- Volumes Groups
- Physical Volumes
- Logical Volumes

### "Volume Group" ###
É o nome dado a um agrupamento de discos fisicos, para construir um sistema LVM tipicamente preciariamos de apenas um grupo de volumes, porém mais grupos podem ser criados a titulo de organização estrutural, por exemplo, é comum o sistema operacional utilizar um grupo de volumes próprio criado na configuração da distro e ingualmente comum que o sysadmin decida criar um novo grupo de volumes unicamente para armazenar os discos dedicados a uma determinada aplicação.

### "Physical Volumes" ###
O conceito de Volume Físico é mais simples e auto esclicativo, um volume simples corresponde a um disco ou partição que fora "entregue" ao sistema LVM para ser usada como recurso na composição de grupos de volumes.

### "Logical Volumes" ###
Volumes logicos correspondem a partições, eles serão os itens a serem formatados aplicando um sistema de arquivos e montados para uso, diferente do que ocorre nas partições volumes lógicos são identificados por NOMES e não por números ( UUID ) e podem se estender por varios discos, ou seja, dois discos de 20 GB podem ser usados para entregar um volume de 40 GB ai está o pulo do gato do uso de LVM.

> Uma das maiores vantagens do LVM é que a maioria das operações podem ser feitas "on the fly" em tempo real com sistema ainda em execução. 
> A maioria das operações que você pode fazer com gparted exigem que as partições que você está tentando manipular não estejam em uso,
> Consequentemente se estivermos falando de uma alteração na raiz do sistema você precisaria executar um boot a partir do Live CD.

## Comandos basicos para manipulação de lvm:

Para manipular partições utilizando lvm é necessário que o pacote lvm2 esteja instalado, nas versões mais novas de sistemas linux esse pacote compoe a instalação do sistema operacional visto que muitos sistemas utilizam lvm na montagem da própria raiz.

### Criando uma partição utilizando lvm:

Uma vez confirmada a existência do pacote, em primeiro lugar, você precisará de um volume físico. Normalmente você começa com um disco rígido, e cria uma partição tipo LVM nele, o que pode ser feito com o gparted ou o fdisk por exemplo, nesse ponto você poderá opinar por entregar o disco inteiro ao sistema de LVM ou apenas uma unica partição de seu disco.

 1- Depois de ter sua partição LVM , é preciso inicializar-la como um volume físico . Assumindo que esta partição é /dev/sdb1:

```sh
sudo pvcreate /dev/sdb1
pvs
```

O comando **pvs** utilizado acima permite a visualização das partições entregues a confiração de LVM, ou seja, as partições que compõem os seus Volumes Físicos, de forma similar utilizaremos os comandos **vgs** e **lvs** para visualizar Grupos de volumes e Volumes Lógicos respectivamente. 

> Do ponto de vista técnico o uso de partições só se torna interessante caso deseje utilizar o resto do disco para outras finalidades, do contrário podemos entregar o disco inteiro e nesse caso, nem mesmo o particionamento será necessário, uma vez que LVM irá lidar com subdivisões em volumes lógicos.

 2- Após a definição dos discos utilizados criamos nosso pool de recursos, um volume group, neste exemplo ele receberá o nome "foo":

```sh
sudo vgcreate foo /dev/sdb1
vgs
```

 3- Criado o grupo de volumes já temos os recursos necessários para construção de nossa partição:

```sh
sudo lvcreate -n bar -L 30G foo
lvs
ls -l /dev/mapper/
lvdisplay
```

O comando executado acima cria um Volume Lógico chamado **bar** utilizando o grupo de volumes **foo**, o bloco utilizado na construção das partições lvm pode ser localizado no diretório **/dev/mapper**, trata-se de um link simbólico para a real localização do devide dentro do /dev.

Outra forma de visualizar as execuções acima é utilizando os binários **lvdisplay**, **vgdisplay** e **pvdisplay**

 4- Para finalizar o teste precisamos aplicar um filesystem e montar a partição, para este exemplo utilizei xfs mas você pode escolher outras opções como ext4 ou swap:

```sh
sudo mkfs.xfs /dev/mapper/foo--bar
mount /dev/mapper/foo--bar /mnt && df -h
```

## Ampliando os recursos do LVM:

Aqui o teste de um dos recursos mais interessantes no uso do LVM a manipulação de espaço, considere os exemplos anteriores, o processo para aumento de 10G no ponto de montagem bar seria o seguinte:

 1- Execute o processo de resize com o comando lvextend:

```sh
# lvextend -L +10G /dev/mapper/foo--bar	
```
> O espaço é alocado a partir de qualquer espaço livre em qualquer lugar do Grupo de Volumes nomeado como bar, Um detalhe interessante é que caso você tenha vários volumes físicos compondo o VG, você poderia adicionar os nomes de um ou mais deles no fim do comando e assim especificaria exatamente quais discos devem ser usados para sua alteração.

 2- Depois de estender o volume lógico, você precisa expandir o sistema de arquivos para usar o novo espaço.

- Como no exemplo formatamos utilizando xfs, utilize o utilitário xfs_growfs:

```sh
# sudo xfs_growfs /dev/mapper/foo--bar -D 10G
```

- Com relação a sistemas ext 3/4 o utilitário responsável por este processo é resize2fs, logo a execução do comando seria a seguinte:

```sh
#  sudo resize2fs /dev/mapper/foo--bar
```

Verifique que em ambos os casos o processo é executado SEM que seja necessário demonstar a partição.

3- Caso não haja mais espaço no Volume Group ou por qualquer outro motivo você decida expandilo, utilize o comando vgextend para essa finalizadade:

```sh
# sudo pvcreate /dev/sdb2
# pvs
# sudo vgextend foo /dev/sdb2
# vgs
```

## Material de Referência sobre LVM:

* [Wiki oficial do Ubuntu, BASE para construção desta aula](https://wiki.ubuntu.com/Lvm)
* [Documentação oficial da RedHat 6 ( Valida também para o 7 ) com exemplos de configuração](https://access.redhat.com/documentation/pt-BR/Red_Hat_Enterprise_Linux/6/html/Logical_Volume_Manager_Administration/LVM_examples.html)

----

**Free Software, Hell Yeah!**
