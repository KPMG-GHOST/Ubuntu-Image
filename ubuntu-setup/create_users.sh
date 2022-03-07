#!/bin/bash

# check for file input
if [$# -eq 0]
   then
     echo "Missing File Argument. Ex: create_users.sh filename.txt"
     exit 1
fi

filename=$1

declare -a userArray=()

# Read in the user names
while IFS= read -r line
   do
      asArray=($line)
      first=${asArray[0]}
      fInitial=${first[0]:0:1}
      last=${asArray[1]}
      usr="$fInitial$last"
      usrlower="${usr,,}"
      if [[ $usrlower ]];
        then
          echo "Username: $usrlower"
          userArray+=("$usrlower")
      fi
   done < "$filename"

count=0

# Create the user homes
for usr in ${userArray[@]}; 
   do
     echo "adding: $usr"
     sudo useradd -m -G sudo $usr
     echo "Return Code: $?"
     ((count++))
   done

# Create passwords
for usr in ${userArray[@]};
   do 
     echo "Changing password for $usr"
     echo "$usr:password" | chpasswd
   done 

echo "From /etc/passwd:"
tail -n $count /etc/passwd

echo "Copying contents for rdp"
# Copy the contents of the .xsession and .xessionrc to the homes
for usr in ${userArray[@]}; 
   do
     echo "Copying contents to /home/$usr"
     cp /home/ehosinski/.xsession /home/$usr/
     cp /home/ehosinski/.xsessionrc /home/$usr/
     chown $usr /home/$usr/.xsession
     chown $usr /home/$usr/.xsessionrc
     chgrp $usr /home/$usr/.xsession
     chgrp $usr /home/$usr/.xsessionrc
   done

exit 1

