# Docker Image Update Notifier (DIUN)
The Docker Image Update Notifier, affectionately known as DIUN, is a sleek CLI application written in Go and served up as a nifty, standalone executable (with a side of Docker image) to keep you in the loop whenever a Docker image gets ~~a fresh coat of paint on a Docker registry~~ an update.

For me, DIUN is my trusty sidekick in the realm of image version tracking, adding an extra layer of finesse to my patch management endeavors.

### Setting the Stage
Before diving headfirst into the DIUN experience, let's lay down the groundwork. Begin by downloading and extracting diun:

`wget -qO- https://github.com/crazy-max/diun/releases/download/v4.28.0/diun_4.28.0_linux_amd64.tar.gz | tar -zxvf - diun`

After getting the binary, it can be tested with `./diun --help` command

### Prepare environment
Create a dedicated user to run DIUN:
`groupadd diun`
`useradd -s /bin/false -d /bin/null -g diun diun`

Next up, let's lay down the directory infrastructure for DIUN:

`mkdir -p /var/lib/diun`
`chown diun:diun /var/lib/diun/`
`chmod -R 750 /var/lib/diun/`
`mkdir /etc/diun`
`chown diun:diun /etc/diun`
`chmod 770 /etc/diun`

Create your first configuration file at /etc/diun/diun.yml or use mine as a starting point.

Next change the permissions of the diun.yaml config file:

`chown diun:diun /etc/diun/diun.yml`
`chmod 644 /etc/diun/diun.yml`

Move the diun binary:
`cp diun /usr/local/bin/diun`

Modify the slack webhook URL, templateBody and providers as required.
Copy over the images.yaml file to the `/etc/diun/images.yaml` if required.

And voilà! Your DIUN deployment is primed and ready for action. But wait, there's more! For added convenience, fashion a cozy systemd service for DIUN.
To create a new service, copy the `diun.service` file into `/etc/systemd/system/diun.service`.

Finally enable the diun service:
`sudo systemctl enable diun`
`sudo systemctl start diun`

Now, if you ever need to peek under the hood and see what DIUN is up to, run this command:
`journalctl -fu diun.service`