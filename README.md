# yt-dlp Docker

Docker container for [yt-dlp](https://github.com/yt-dlp/yt-dlp) project for personal use.

## Build container

### Step 1

* Copy your public key of SSH identity file(*.pub) in this directory and rename it to `youtube.pub`.

```sh
COPY --chown=$USERNAME:$USERGROUP ./youtube.pub /home/$USERNAME/.ssh/authorized_keys
```

### Step 2

* Modify `yt-dlp.conf` file to your preference, except for the download directory(`-P` flag).

### Step 3

* Run the following command with the root privilege.
* Substitue `<username>`, `<password>` with the username and password you will use to connect via SSH.

```sh
docker build \
    --build-arg USERNAME=<username> \
    --build-arg PASSWORD=<password> \
    -t yt:0.2.1
```

## Deploy container

* Substitue `<ssh-port>`, `<download-dir>` with the SSH port to access the system and the directory to save downloaded files.
* Substitue `<username>` with the username you have used during the build before.
* Only needed once right after built.

```sh
docker run -d \
    -p <ssh-port>:22 \
    -v <download-dir>:/home/<username>/downloads \
    --name yt \
    yt:0.2.1
```

## Start and stop container

* Start: `docker start yt`
    - Unnecessary when deployed. Only after stopped.
* Stop: `docker stop yt`

## How to use

* Access the system via SSH. Config SSH config file with `<ssh-port>`, `<username>` and the identity file.
* Run command: `yt-dlp <video-url>`
    - Options in the `yt-dlp.conf` files are applied by default, so best quality videos will be downloaded in the downloads directory by default.
* Access the downloaded files from the host computer.

## TODO

* Change host-side volume UID, whilst SSHD should be run with root privilege.
