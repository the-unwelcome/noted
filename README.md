# noted
Script to create AES-encrypted notes, written in POSIX sh.

## Deps
This program requires `openssl` as it handles encryption and decryption. On most systems, this should be installed by default.

## Usage
`noted [-f/--file] FILE`: creates and launches the editor for a new note with the name FILE. The user will be prompted for a password for the note through stdin after saving the file in the editor.

`noted [-r/--read] FILE`: decrypts and reads the contents of the note with the name FILE. The user will be prompted for the note's password through stdin.

`noted [-d/--delete] FILE`: deletes the note with the name FILE. It cannot be recovered. There is no confirmation, it's just deleted.

`noted [-e/--edit] FILE`: launches the editor to make changes to a note with the name FILE. Before the editor is launched, the user is asked for the note's password through stdin.

`noted [-l/--list]`: writes the name of every note to stdout.

`noted [-h/--help]`: prints the help dialogue.

## Installation
```sh
curl -fsSL https://github.com/the-unwelcome/noted/raw/main/noted.sh -o noted && chmod a+x noted
```

## Uninstallation
Just remove the `noted` file.

## Screenshots
![image](https://user-images.githubusercontent.com/64506392/208986409-bd27c8ed-b3bd-4a6b-8a7b-0f1b1209393f.png)

![image](https://user-images.githubusercontent.com/64506392/208986547-74f71cd0-ff61-4122-9b2b-611e2f7ea0fe.png)
