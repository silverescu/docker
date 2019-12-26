FROM ubuntu:latest

# Update and install needed packages

RUN apt update && apt upgrade -y --no-install-recommends

RUN apt-get install -y build-essential \
  git \
  libfuse-dev \
  libcurl4-openssl-dev \
  libxml2-dev \
  mime-support \
  automake \
  libtool \
  pkg-config \
  libssl-dev \
  python3-pip \
  vsftpd \
  curl \
  supervisor

RUN pip3 install awscli && \
  cd home && \
  git clone https://github.com/s3fs-fuse/s3fs-fuse && \
  cd s3fs-fuse && \
  git checkout tags/v1.85 && \
  ./autogen.sh && \
  ./configure --prefix=/usr --with-openssl && \
  make && \
  make install && \
  mkdir -p /home/aws/s3bucket/ 

# Copy scripts to /usr/local
COPY ["s3-fuse.sh", "users.sh", "/usr/local/"]

# Copy needed config files to their destinations
COPY vsftpd.conf /etc/vsftpd.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ftp and sftp ports
EXPOSE 21

# Run supervisord at container start
CMD ["/usr/bin/supervisord"]