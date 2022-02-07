# Pre-requisites software (Locally if Windows OS-64bit)

If you alrady have vagarnt and oracle virtual box installed, then kindly uninstall first.

- Vagrant (2.2.19) : https://releases.hashicorp.com/vagrant/2.2.19/vagrant_2.2.19_x86_64.msi
- Oracle Virtual Box (6.1.32) : https://download.virtualbox.org/virtualbox/6.1.32/VirtualBox-6.1.32-149290-Win.exe
- Git Bash : https://github.com/git-for-windows/git/releases/download/v2.35.1.windows.2/Git-2.35.1.2-64-bit.exe

# Pre-requisites software (Cloud if Ubuntu OS)

sudo apt-get update

sudo apt-get install ca-certificates curl gnupg lsb-release

1) Git 

sudo apt-get install git

2) cURL

sudo apt-get install curl

3) Docker and Docker-compose

https://docs.docker.com/engine/install/ubuntu/

https://docs.docker.com/compose/install/

docker-compose --version
docker --version

Make sure the Docker daemon is running.
sudo systemctl start docker

Optional: If you want the Docker daemon to start when the system starts, use the following:
sudo systemctl enable docker

Add your user to the Docker group
sudo usermod -a -G docker <username>

4) Go

https://devmohit.medium.com/install-golang-setting-up-its-path-and-env-variable-cafae8c9f54

5) Jq

sudo apt-get install jq








