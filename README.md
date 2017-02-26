# SQLaaSPoC
Scripts and other files relating to a "SQL as a Service" Proof of Concept I made with VMware's vRealize Automation product, as detailed in an [article](https://www.linkedin.com/pulse/sql-service-proof-concept-2012-vrealize-automation-jesse-boyce) on Linkedin I wrote in 2016.  Where possible I've tried to sanitise the content.  Given that this was a POC, the code is neither pretty nor does it have any real input validation or error handling.

## Folder Details
- *Exports* - Individual components exported using CloudClient
- *PowershellScripts* - Individual Powerscript script items
- *YAMLFiles* - Individual component YAML files and master blueprint YAML file

## Placeholder Settings
Some references to servers, domains, accounts, etc were done via Properties.  Some were hard-coded into the scripts themselves.  Some are explained below:

- *contoso.com or contoso* - Placeholder for the Active Directory domain to be used
- *vRA-CL-Admin* - Cluster Admin account with the rights to create the cluster object
- *vRA-Dom-Join* - Account with rights to join the servers to the domain
- *vra-ipam* - Account with rights to perform actions on IPAM system
- *SQLAAS SQL Administrators* - AD group added as SQL admins during the installation
- *dnssvr.contoso.com* - Generic name for DNS server of the domain (refereneced when creating DNS records)
- *ipamsvr.contoso.com* - IPAM server of the domain (referenced for IP reservations)
- *filesvr* - Server hosting SQL install files

Computer/cluster objects were created in sub-OUs of OU=vRealize,DC=contoso,DC=com
