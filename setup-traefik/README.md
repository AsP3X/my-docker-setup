# Create Traefik and Portainer
`Traefik and portainer with docker and letsencrypt`
<br>

## Step 1:
  - create following folder structure at a location of your choise

  ```tree
  traefik/
  |-- data
  |   |-- letsencrypt
  |   `-- portainer-data
  `-- docker-compose.yml
  ```
  <br>

  - then create a `.env` file with the following content:
  ```dotenv
  DOMAIN=YOUR_DOMAIN
  EMAIL=YOUR_EMAIL
  CERT_RESOLVER=letsencrypt
  TRAEFIK_USER=root
  TRAEFIK_PASSWORD_HASH=YOUR_PASSWORD_HASH
  ```
  <br>

  - generate a password hash with the following command:
  `htpasswd -nBC 10 root`
  - take the part after the `root:` and put it in the `TRAEFIK_PASSWORD_HASH` variable

## Step 2:
  - install following packages:
  ```bash
  sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

  sudo apt update
  sudo apt install docker-ce
  ```

