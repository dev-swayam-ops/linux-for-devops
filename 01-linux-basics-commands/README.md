# linux-basics-commands

## ls Command Options and Sample Output

---

## ls
Lists files and directories in the current directory.

![ls command output](Screenshots/image.png)

---

## ls -a
Lists all files, including hidden files (files starting with `.`).

![ls -a command output](Screenshots/image-1.png)

---

## ls -l
Lists files in long format showing permissions, ownership, size, and timestamps.

![ls -l command output](Screenshots/image-2.png)

---

## ls -lh
Lists files in long format with human-readable file sizes.

![ls -lh command output](Screenshots/image-3.png)

---

## ls -lr
Lists files in reverse alphabetical order.

![ls -lr command output](Screenshots/image-4.png)

---

## ls -ltr
Lists files in long format sorted by modification time (oldest first).

![ls -ltr command output](Screenshots/image-5.png)

---

## cd
Changes the current working directory.
## cd ..
Moves to the parent directory.
## cd ~
Moves to the home directory.
## cd -
Switches to the previous directory.

![alt text](Screenshots/image-9.png)
---

## mkdir
Creates a new directory.
## mkdir -p
Creates parent directories if they do not exist.
## mkdir -v
Displays a message for each created directory.

![alt text](Screenshots/image-6.png)

---

## rmdir
Deletes an empty directory.
## rmdir -p
Deletes parent directories if they are empty.
## rmdir -v
Displays a message for each removed directory.

![alt text](Screenshots/image-7.png)

---

## pwd
Prints the current working directory.
## pwd -L
Prints the logical path (default).
## pwd -P
Prints the physical path (resolves symbolic links).

![alt text](Screenshots/image-10.png)
---

## touch
Creates an empty file or updates file timestamps.
## touch -c
Does not create a file if it does not exist.
## touch -t 
Sets a specific timestamp for a file.
(touch -t [[CC]YY]MMDDhhmm[.ss] file)

![alt text](Screenshots/image-12.png)
---

## rm
Deletes files or directories.
## rm -r
Deletes directories and their contents recursively.
## rm -f
Forces deletion without confirmation.
## rm -i
Prompts before each deletion.

![alt text](Screenshots/image-11.png)
---

## mv
Moves or renames files and directories.
## mv -v
Displays verbose output.

![alt text](Screenshots/image-13.png)
---

## cp
Copies files or directories.
## cp -r
Copies directories recursively.
## cp -v
Displays verbose output.

![alt text](Screenshots/image-14.png)

---

## cat
Displays the contents of a file.
## cat -n
Numbers all output lines.
## cat -b
Numbers only non-empty lines.
## cat -A
Displays all characters including tabs and line endings.
![alt text](Screenshots/image-8.png)
---

## more
Displays file contents one screen at a time (forward only).
## more -d
Displays help prompt instead of ringing the bell.
## more -f
Counts logical lines instead of wrapped lines.

---

## less
Displays file contents with forward and backward navigation.
## less -N
Displays line numbers.
## less -S
Disables line wrapping.
## less +F
Follows file updates (similar to `tail -f`).

---

## head
Displays the first 10 lines of a file.
## head -n
Displays a specified number of lines.
## head -c
Displays a specified number of bytes.

![alt text](Screenshots/image-15.png)
---

## tail
Displays the last 10 lines of a file.
## tail -n
Displays a specified number of lines.
## tail -c
Displays a specified number of bytes.
## tail -f
Follows file updates in real time (commonly used for logs).

![alt text](Screenshots/image-16.png)
---

## rev
Reverses each line of input text character-wise.

![alt text](Screenshots/image-17.png)
---
