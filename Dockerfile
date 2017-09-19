#
# This Dockerfile creates a Jenkins build-node for running build jobs in Jenkins for Angularjs projects.
#
FROM centos:7.3.1611
MAINTAINER Chandra Sekhar Eswa <e.chandrasekhar@gmail.com>

ENV NVM_VERSION=v0.32.1 \
    NODE_VERSION=v4.7.2 \
    PHANTOM_VERSION=1.9.8 \
    RUBY_VERSION=2.3.3

# Install and configure packages that are required by jenkins docker plugin. Also create jenkins user.
# Note: Jenkins installs java automatically if it is not found from the image.
# This would slow down the node creation so we install it here.
RUN yum install -y openssh-server && \
    yum install -y java-1.8.0-openjdk && \
    yum clean all && \
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    /usr/bin/ssh-keygen -A && \
    useradd jenkins -m -s /bin/bash && \
    echo "jenkins:jenkins" | chpasswd

# Install packages that are needed by the build jobs
RUN yum install -y git which make bzip2 wget gcc-c++ && \
    yum -y install freetype-devel && \
    yum -y install libtool-ltdl-devel && \
    yum -y install libpng-devel && \
    yum -y install libtiff-devel && \
    yum -y install libjpeg-devel && \
    yum -y install libicu-devel && \
    yum -y install python-devel && \
    yum -y install bzip2-devel && \
    yum -y install bzip2 && \
    yum -y install xorg-x11-server-Xvfb.x86_64 && \
    yum clean all

#Install Phantomjs
RUN wget --directory-prefix=/tmp/ https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-${PHANTOM_VERSION}-linux-x86_64.tar.bz2 && \
    mkdir -p /opt/phantomjs && \
    tar -C /opt/phantomjs --strip-components 1 -xjvf /tmp/phantomjs-${PHANTOM_VERSION}-linux-x86_64.tar.bz2 && \
    ln -s /opt/phantomjs/bin/phantomjs /usr/bin/phantomjs && \
    rm /tmp/phantomjs*

#Install Ruby and its dependencies
RUN yum -y install patch readline readline-devel zlib zlib-devel && \
    yum -y install libyaml-devel libffi-devel openssl-devel && \
    yum -y install bzip2 autoconf automake libtool bison iconv-devel sqlite-devel && \
    yum clean all && \
    gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
    curl -L get.rvm.io | bash -s stable && \
    /bin/bash -lc "source /etc/profile.d/rvm.sh; rvm install ${RUBY_VERSION}; rvm use ${RUBY_VERSION} --default"

#Install compass, sass, jekyll (and its dependecies: bundler, jekyll-feed, minima)
RUN /bin/bash -lc "source /etc/profile.d/rvm.sh && gem install compass sass jekyll bundler jekyll-feed minima"

# Install nvm and nodejs as jenkins user
USER jenkins
WORKDIR /home/jenkins

# Install nvm, nodejs and required global tools
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/${NVM_VERSION}/install.sh | bash && \
    source ~/.nvm/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    npm install -g grunt grunt-cli grunt-contrib-imagemin && \
    npm install -g bower bower-requirejs && \
    npm install -g karma karma-cli protractor && \
    npm install -g bower-nexus3-resolver

USER root

# This will configure bower and npm clients to use Tecnotree Nexus as proxy
COPY npmrc /home/jenkins/.npmrc
COPY bowerrc /home/jenkins/.bowerrc
RUN chown jenkins:jenkins /home/jenkins/.npmrc /home/jenkins/.bowerrc

# Expose SSH port and run sshd
EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]
