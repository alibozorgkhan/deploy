FROM ubuntu:15.04
MAINTAINER Ali Bozorgkhan "ali@goventurelab.com"

#   Create "vlab" user
RUN useradd -m vlab
RUN echo "vlab:vlab" | chpasswd

#   Install apache, python, git
RUN apt-get update
RUN apt-get install -y apache2 libapache2-mod-wsgi
RUN apt-get install -y libpq-dev python-dev python-setuptools python-pip

#   Virtual env
RUN pip install virtualenv
RUN virtualenv --no-site-packages /opt/virtual_envs/vlab

#   Add this project to vlab/app
ADD . /home/vlab/app

#   Django preparation
RUN /opt/virtual_envs/vlab/bin/pip install -r /home/vlab/app/requirements.txt
ENV DJANGO_SETTINGS_MODULE deploy.settings
RUN (cd /home/vlab/app && /opt/virtual_envs/vlab/bin/python manage.py migrate --noinput)

#   Apache2
ADD apache.conf /etc/apache2/sites-available/
RUN a2dissite 000-default
RUN a2ensite apache

ENV APACHE_RUN_USER vlab
ENV APACHE_RUN_GROUP vlab
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_LOG_DIR /var/log/apache2

EXPOSE 80

ENTRYPOINT ["/usr/sbin/apache2", "-DFOREGROUND"]
