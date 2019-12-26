### Create env.list

Use env.list.example to create env.list file


### Build container from image

docker build --rm -t drzvt/s3fs-fuse-cctv:1.0 .

### Start container 

docker run --restart=always -ti -p 21:21 -p 30000-30100:30000-30100 --privileged --env-file env.list drzvt/s3fs-fuse-cctv:1.0

### Get shell access into running container 

docker exec -it <Container_ID> /bin/bash



######################################################################
########################S3FS-FUSE#####################################
######################################################################

### Setting up S3fs-fuse on Amazon linux with IAM role

### Create s3 bucket

### Create new role with the following policy

{
   "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["s3:ListBucket"],
            "Resource": ["arn:aws:s3:::ca-s3fs-bucket"]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": ["arn:aws:s3:::ca-s3fs-bucket/*"]
        }
    ]
}

### Launch EC2 instance with the new created role

### Install s3fs-fuse

sudo yum install -y gcc libstdc++-devel gcc-c++ fuse fuse-devel curl-devel libxml2-devel mailcap automake openssl-devel make git

git clone https://github.com/s3fs-fuse/s3fs-fuse.git s3fs-fuse

cd s3fs-fuse

git checkout tags/v1.85 # There is a problem with the last version of s3fs at the time of creating this and to be able to use the atached role of the instance 
                          we need to use a previous version of s3fs to make this work

./autogen.sh

./configure --prefix=/usr

make

sudo make install

### Testing s3fs 

which s3fs

s3fs --version

mkdir test

s3fs -o iam_role="s3fs" -o url="https://<s3_url_for_region>" -o endpoint=<region> -o dbglevel=info -o curldbg -o use_cache=/tmp <bucket_name> <path/to/mount/dir>

s3fs -o iam_role="s3fs" -o url="https://s3.amazonaws.com" -o endpoint=us-east-1 -o dbglevel=info -o curldbg -o use_cache=/tmp drzvt /home/aws/s3bucket/ftp-users/cctv1

df -Th

cd test

touch file.txt

### Check s3 to see if the file is in the bucket


### Install ftp server

sudo yum install vsftpd

### Edit ftp server configuration file 

sudo nano /etc/vsftpd/vsftpd.conf

### Remove everything in config and paste the next config file

    ---
    # The default compiled in settings are fairly paranoid. This sample file
    # loosens things up a bit, to make the ftp daemon more usable.
    # Please see vsftpd.conf.5 for all compiled in defaults.
    #
    # READ THIS: This example file is NOT an exhaustive list of vsftpd options.
    # Please read the vsftpd.conf.5 manual page to get a full idea of vsftpd's
    # capabilities.
    #
    #
    # Run standalone?  vsftpd can run either from an inetd or as a standalone
    # daemon started from an initscript.
    listen=YES

    # Run standalone with IPv6?
    # Like the listen parameter, except vsftpd will listen on an IPv6 socket
    # instead of an IPv4 one. This parameter and the listen parameter are mutually
    # exclusive.
    #listen_ipv6=YES

    # Allow anonymous FTP? (Disabled by default)
    anonymous_enable=NO

    # Uncomment this to allow local users to log in.
    local_enable=YES

    # Uncomment this to enable any form of FTP write command.
    write_enable=YES

    # Default umask for local users is 077. You may wish to change this to 022,
    # if your users expect that (022 is used by most other ftpd's)
    local_umask=022

    # Activate directory messages - messages given to remote users when they
    # go into a certain directory.
    dirmessage_enable=YES

    # If enabled, vsftpd will display directory listings with the time
    # in  your  local  time  zone.  The default is to display GMT. The
    # times returned by the MDTM FTP command are also affected by this
    # option.
    use_localtime=YES

    # Activate logging of uploads/downloads.
    #xferlog_enable=YES

    # Make sure PORT transfer connections originate from port 20 (ftp-data).
    connect_from_port_20=YES

    # You may override where the log file goes if you like. The default is shown
    # below.
    #xferlog_file=/var/log/vsftpd.log

    # If you want, you can have your log file in standard ftpd xferlog format.
    # Note that the default log file location is /var/log/xferlog in this case.
    #xferlog_std_format=YES

    # You may change the default value for timing out an idle session.
    #idle_session_timeout=600

    # You may change the default value for timing out a data connection.
    #data_connection_timeout=120

    # It is recommended that you define on your system a unique user which the
    # ftp server can use as a totally isolated and unprivileged user.
    #nopriv_user=ftpsecure

    # Enable this and the server will recognise asynchronous ABOR requests. Not
    # recommended for security (the code is non-trivial). Not enabling it,
    # however, may confuse older FTP clients.
    #async_abor_enable=YES

    # By default the server will pretend to allow ASCII mode but in fact ignore
    # the request. Turn on the below options to have the server actually do ASCII
    # mangling on files when in ASCII mode.
    # Beware that on some FTP servers, ASCII support allows a denial of service
    # attack (DoS) via the command "SIZE /big/file" in ASCII mode. vsftpd
    # predicted this attack and has always been safe, reporting the size of the
    # raw file.
    # ASCII mangling is a horrible feature of the protocol.
    #ascii_upload_enable=YES
    #ascii_download_enable=YES

    # You may fully customise the login banner string:
    #ftpd_banner=Welcome to blah FTP service.

    # You may specify a file of disallowed anonymous e-mail addresses. Apparently
    # useful for combatting certain DoS attacks.
    #deny_email_enable=YES
    # (default follows)
    #banned_email_file=/etc/vsftpd.banned_emails

    # You may restrict local users to their home directories.  See the FAQ for
    # the possible risks in this before using chroot_local_user or
    # chroot_list_enable below.
    #chroot_local_user=YES

    # You may specify an explicit list of local users to chroot() to their home
    # directory. If chroot_local_user is YES, then this list becomes a list of
    # users to NOT chroot().
    # (Warning! chroot'ing can be very dangerous. If using chroot, make sure that
    # the user does not have write access to the top level directory within the
    # chroot)

    chroot_local_user=YES
    chroot_list_enable=NO
    allow_writeable_chroot=YES

    # This option should be the name of a directory which is empty.  Also, the
    # directory should not be writable by the ftp user. This directory is used
    # as a secure chroot() jail at times vsftpd does not require filesystem
    # access.
    secure_chroot_dir=/home/aws/s3bucket/ftp-users

    #chroot_list_enable=YES
    # (default follows)
    #chroot_list_file=/etc/vsftpd.chroot_list

    # You may activate the "-R" option to the builtin ls. This is disabled by
    # default to avoid remote users being able to cause excessive I/O on large
    # sites. However, some broken FTP clients such as "ncftp" and "mirror" assume
    # the presence of the "-R" option, so there is a strong case for enabling it.
    #ls_recurse_enable=YES

    # Customization

    # Some of vsftpd's settings don't fit the filesystem layout by
    # default.

    # This string is the name of the PAM service vsftpd will use.
    pam_service_name=vsftpd

    # This option specifies the location of the RSA certificate to use for SSL
    # encrypted connections.
    rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
    # This option specifies the location of the RSA key to use for SSL
    # encrypted connections.
    rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key

    pasv_address=<server_ip>
    pasv_enable=Yes
    pasv_min_port=30000
    pasv_max_port=30100
    port_enable=YES

    # Change ftp port from default 21
    #listen_port=21

    # Set a custom location for vsftpd log file
    #vsftpd_log_file=/var/log/vsftpd.log

    # Set up better log output
    xferlog_enable=YES
    xferlog_std_format=NO
    dual_log_enable=YES
    log_ftp_protocol=YES

    ---


### Create a new group for our ftp users

groupadd ftpaccess

# Create a directory where all ftp/sftp users home directories will go

mkdir -p /home/aws/s3bucket/ftp-users

chown root:root /home/aws/s3bucket/ftp-users

chmod 750 /home/aws/s3bucket/ftp-users

### Create users, add it to set users directory 
### in docker users need to be created every time when it starts since stopping the docker container gets rid of users

useradd -d /home/aws/s3bucket/ftp-users/cctv1 

usermod -G ftpaccess cctv1

### # Directory exists but permissions for it have to be setup anyway.

chown root:ftpaccess /home/aws/s3bucket/ftp-users

chmod 750 /home/aws/s3bucket/ftp-users

chown cctv1:ftpaccess /home/aws/s3bucket/ftp-users/cctv1

chmod 750 /home/aws/s3bucket/ftp-users/cctv1

### Test ftp connection and file transfer. Check S3 bucket.



