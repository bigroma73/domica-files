#!/bin/sh
wall "Cronmanager called ipkg Update script !"
echo "Checking Internet for ipkg Updates and installing them"
ipkg update
ipkg upgrade
echo "ipk Upgrade Done !"
exit 0
