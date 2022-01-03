# Create Traefik and Portainer [UBUNTU]
`Traefik and portainer with docker and letsencrypt`
<br>

## ORDER:
- Create folder structure
- Create .env file with configuration
- Generate password hash
- Install packages

## Step 1:
  - Create following folder structure at a location of your choise

  ```tree
  traefik/
  |-- data
  |   |-- letsencrypt
  |   `-- portainer-data
  `-- docker-compose.yml
  ```
  <br>

  - Then create a `.env` file with the following content:
  ```dotenv
  DOMAIN=YOUR_DOMAIN
  EMAIL=YOUR_EMAIL
  CERT_RESOLVER=letsencrypt
  TRAEFIK_USER=root
  TRAEFIK_PASSWORD_HASH=YOUR_PASSWORD_HASH
  ```
  <br>

  - Generate a password hash with the following command:
  `htpasswd -nBC 10 root`
  - Take the part after the `root:` and put it in the `TRAEFIK_PASSWORD_HASH` variable

## Step 2:
  - Install docker on your machine:
  
  Make sure you are using ubuntu otherwise you have to install docker via the instructions on the docker website for the linux install you are using.

  ```bash
  $ sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
  $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

  $ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

  $ sudo apt update
  $ sudo apt install docker-ce
  ```
  <br>

  - Install docker-compose on your machine:
  ```bash
  $ sudo apt install docker-compose
  ```

## Step 3:
  - Check if docker is running on your machine:
  `sudo systemctl status docker`

  - Add your user to the docker group:
  `sudo usermod -aG docker ${USER}`

  - Please relogin to your machine to make sure your user is added to the docker group.
  `id -nG`

<hr>
<br>
<br>

# Setup Traefik and Portainer
`Traefik and portainer with docker and letsencrypt`

## Step 1:
  ```DNS
  If not already done create the following DNS A-Records:

  *.YOURDOMAIN.END  => SERVERIP
  YOURDOMAIN.END    => SERVERIP
  ```

## Step 2:
  - Create the traefik-proxy network:
  ```bash
  $ docker network create traefik-proxy
  ```
  
  - Start the docker containers:
  ```bash
  $ cd traefik
  $ docker-compose up
  ```

  - Check if the containers are running and no errors occured:

  - Then stop the containers and restart them in the background:
  ```bash
  $ docker-compose down
  $ docker-compose up -d
  ```

## Step 3:
  - Check if traefik is accessible via:
  `https://traefik.YOURDOMAIN.END`
  - Check if traefik has no errors on the page of the traefik dashboard

  ---
  - Check if portainer is accessible via:
  `https://portainer.YOURDOMAIN.END`
  - Check if portainer has no errors on the page of the portainer dashboard