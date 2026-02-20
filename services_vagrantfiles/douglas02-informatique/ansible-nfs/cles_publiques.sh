# Récupère les clés publiques des 4 clients
ssh-keyscan userinfo.prive.blanc.iut. >> ~/.ssh/known_hosts
ssh-keyscan useradmin1.prive.blanc.iut. >> ~/.ssh/known_hosts
ssh-keyscan useradmin2.prive.blanc.iut. >> ~/.ssh/known_hosts
ssh-keyscan userprod1.prive.blanc.iut. >> ~/.ssh/known_hosts
ssh-keyscan userprod2.prive.blanc.iut. >> ~/.ssh/known_hosts