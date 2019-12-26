#!/bin/bash

FTP_DIRECTORY="/home/aws/s3bucket/ftp-users"

# Create a group for ftp users
groupadd ftpaccess


# Create a directory where all ftp/sftp users home directories will go
mkdir -p $FTP_DIRECTORY
chown root:root $FTP_DIRECTORY
chmod 755 $FTP_DIRECTORY

# Expecing an environment variable called USERS to look like "bob:hashedbobspassword steve:hashedstevespassword"
for u in $USERS; do
  
  read username passwd <<< $(echo $u | sed 's/:/ /g')

  # User needs to be created every time since stopping the docker container gets rid of users.
  useradd -d "$FTP_DIRECTORY/$username" $username
  usermod -G ftpaccess $username

  # set the users password
  echo $u | chpasswd
  
  if [ -z "$username" ] || [ -z "$passwd" ]; then
    echo "Invalid username:password combination '$u': please fix to create '$username'"
    continue
  elif [ -d "$FTP_DIRECTORY/$username" ]; then
    echo "Skipping creation of '$username' directory: already exists"

    # Directory exists but permissions for it have to be setup anyway.
    chown $username:ftpaccess "$FTP_DIRECTORY/$username"
    chmod 755 "$FTP_DIRECTORY/$username"
    
  else
    echo "Creating '$username' directory..."
    
    # Root must own all directories leading up to and including users home directory
    mkdir -p "$FTP_DIRECTORY/$username"
    chown $username:ftpaccess "$FTP_DIRECTORY/$username"
    chmod 755 "$FTP_DIRECTORY/$username"
    
  fi
  
done
