# Introduction
Contains a few PowerShell scripts that help with rebinding TLS certificates to services (e.g. after an autorenewal event was registered)

# Getting Started
Look at the individual folders for ideas on how to get started.

- IIS >= 8.5 Certificate Rebind (simply creates the scheduled task which would otherwise be created by the IIS Management GUI)
- Windows Admin Center (will also work for any other services registered via netsh). Test if applicable by running "netsh http show sslcert ipport=0.0.0.0:443"
