# How to


### Quick SSH to remote server from Windows

#### Prerequisites
- `Windows host`
- `Ubuntu\Linux remote`
- `Git Bash for Windows`

#### Generate SSH keys

> Open Git Bash and run

- `ssh-keygen -t rsa`

> Press enter through all the questions.  
> This will create a public and a private key in **C:\Users\YOUR_USERNAME\ .ssh** called **id_rsa** and **id_rsa.pub**  

#### Add SSH public key to the server

> Log in to your server  
> Make sure that the **~/.ssh/authorized_keys** file exists.  
> If not create it.

- `mkdir ~/.ssh`
- `touch  ~/.ssh/authorized_keys`

  ##### Run the command
  
  > Switch to Git Bash  
  > Replace the **USERNAME** and **IP** with your server credentials.  
  > Enter the password if promted.
  
  - `cat ~/.ssh/id_rsa.pub | ssh USERNAME@IP "cat >> ~/.ssh/authorized_keys"`

#### Create a bash alias for your SSH connection

> Make sure that **~/.bashrc** file exist on your Windows machine.  
> If not create it.

- `touch  ~/.bashrc`

##### Run the command

> Replace **YOUR_ALIAS** with your alias of choice  
> Replace the **USERNAME** and **IP** with your server credentials.

- `echo "alias YOUR_ALIAS='ssh USERNAME@IP -i ~/.ssh/id_rsa'" >> ~/.bashrc`
- `source ~/.bashrc`

#### Connect

> Open Git Bash and type **YOUR_ALIAS** from above  
> **You should now be connected**
