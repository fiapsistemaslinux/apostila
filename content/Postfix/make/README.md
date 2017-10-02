# Configure Postfix for Labs

## Description:

This basic script is used to configure postfix and bind9 to the following advanced labs:

- Postfix imap tests;
- Postfix pop tests;
- Postfix relay tests;
- Postfix Roundcube webmail configuration;
- Postfix ldap authentication;

## Install

1. First enure that you have python-pip instaled:

```sh
# apt install python-pip
```

2. Than you should generate initial templates using prepare:

```sh
# pip install requeriments.txt
# ./prepare
```

3. The following templates will be created:

```sh
files/
├── dns
│   ├── db.X.X.X
│   ├── db.yourdomain.com
│   └── named.conf.local
└── postfix
    └── main.cf
```

4. Now just run the bash script to install packages:

```sh
# ./install.sh
```

> Until now ( relase v0.1 ) the script only works for Debian based distributions and IPV4 network configuration;
