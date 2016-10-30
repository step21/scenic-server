# sat-metalab/scenic-server

[Scénic](https://github.com/sat-metalab/SCENIC/wiki) is a software platform compatible with various data streams and formats: video, audio, OSC controls, MIDI, data... These data streams are several sources of data that can be reformatted and then exchanged in real time with one or several distant Scénic stations.

This is the SIP+STUN+TURN server used by the development team, packaged in Docker containers. It also includes OpenLDAP server and phpLDAPadmin for user authentication and management.

## Requirements

* [Docker](https://github.com/docker/docker)
* [Docker Compose](https://github.com/docker/compose)

## Quick Start

### Clone this repository:

```shell
git clone https://github.com/sat-metalab/scenic-server.git
```

### Configure your environment

Use your favorite text editor to open docker-compose.yml and set the environment variables to fit your own server:

```yaml
openldap:
  environment:
    LDAP_DOMAIN: example.com                 # Domain that will translate to LDAP base DN (example.com -> dc=example,dc=com)
    LDAP_ORGANIZATION: Example Organization  # Human-friendly organization name
    LDAP_PASSWORD: admin                     # Password for cn=admin,dc={base DN}

phpldapadmin:
  environment:
    VIRTUAL_HOST: pla.example.com            # Virtual host name that will handle requests to phpLDAPadmin

kamailio:
  environment:
    SIP_DOMAIN: example.com                  # SIP domain for registering users
```

You may also want to set a different location for data volumes by replacing all *./volumes* with */srv/scenic-server*, or any other directory.

### Run the application (from the scenic-server directory):

```shell
docker-compose up -d
```

## LDAP User Management

To manage users, you can use *ldapmodify* or *ldapvi* inside the *openldap* container, or log in phpLDAPadmin in your browser, at the URL defined by the VIRTUAL_HOST environment variable. The database administrator is *cn=admin,dc={your base DN}* and the password is the one defined by the LDAP_PASSWORD environment variable.

It is highly recommended that you initialize your LDAP database with this structure (from *init.ldif*):

```ldif
# Groups
dn: ou=Groups,dc=example,dc=com
objectClass: top
objectClass: organizationalUnit
ou: Groups

# Users
dn: ou=Users,dc=example,dc=com
objectClass: top
objectClass: organizationalUnit
ou: Users

# Administrators Group
dn: cn=Administrators,ou=Groups,dc=example,dc=com
objectClass: top
objectClass: groupOfNames
cn: Administrators
member: uid=admin,ou=Users,dc=example,dc=com

# Administrator User
dn: uid=admin,ou=Users,dc=scenic,dc=sat,dc=qc,dc=ca
objectClass: top
objectClass: inetOrgPerson
objectClass: SIPIdentity
uid: admin
cn: Administrator
sn: Administrator
SIPIdentityPassword: admin
userPassword: {SSHA}xKAWNdIgaCaB5EMqnx0Fu/0vrnbgvcjc
```

Users with the *inetOrgPerson* object class will be allowed to log in phpLDAPadmin using their *uid* and *userPassword*. Those who are in the *cn=Administrator* group will be allowed to manage the database.

Users with the *SIPIdentity* class object will be allowed to log in the SIP, STUN and TURN servers using their *uid* and *SIPIdentityPassword*.

## Helper Scripts

Two helper scripts are included:

- **restore_ldif.sh** : Restore a LDAP database
- **update_coturn_users.sh** : Import all LDAP users in the STUN/TURN server database (no automatic import at this time)

### Initialize database

If you want to initialize the LDAP database with the recommended structure, run:

```shell
restore_ldif.sh init.ldif
```

You'll be able to login to phpLDAPadmin using *admin* as both login name and password.
