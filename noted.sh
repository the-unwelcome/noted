#!/bin/sh

_do_init () {
  mkdir "$HOME/Documents/noted"
}

_do_create () {
  outfile="$HOME/Documents/noted/$1.bin"
  touch /tmp/note
  # if the editor command worked...
  "$EDITOR" /tmp/note && {
    # disable echo
    stty -echo
    # if the user exits instead of giving a password, fix echo
    trap "stty echo" EXIT
    printf "Password: "
    read pass
    # enable echo
    stty echo
    printf "\n"
  }

  note="$(cat /tmp/note)"
  rm /tmp/note

  [ -z "$pass" ] && {
    echo "Password is unset - exiting!"
    exit
  }
  touch "$outfile" # create the file for the encrypted note
  echo "$note" | openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -salt -pass pass:"$pass" > "$outfile"
  echo "Created a new note at $outfile!"
}

_do_decrypt () {
  file="$HOME/Documents/noted/$1.bin"
  # disable echo
  stty -echo
  trap "stty echo" EXIT
  printf "Password: "
  read pass
  # enable echo
  stty echo
  printf "\n"

  cat "$file" | openssl enc -aes-256-cbc -md sha512 -d -pbkdf2 -iter 100000 -salt -pass pass:"$pass"
}

_do_delete () {
  file="$HOME/Documents/noted/$1.bin"
  [ -e "$file" ] && {
    rm "$file" && echo "Deleted note '$file' successfully!"
  } || echo "File '$file' does not exist."
}

_do_edit () {
  file="$HOME/Documents/noted/$1.bin"

  # read password
  stty -echo
  trap "stty echo" EXIT
  printf "Password: "
  read pass
  stty echo
  printf "\n"

  # load the old content
  if cat "$file" | openssl enc -aes-256-cbc -md sha512 -d -pbkdf2 -iter 100000 -salt -pass pass:"$pass" 2>/dev/stdout | grep -q "bad decrypt"; then
    echo "Wrong password!"
    exit
  else
    cat "$file" | openssl enc -aes-256-cbc -md sha512 -d -pbkdf2 -iter 100000 -salt -pass pass:"$pass" > /tmp/note
  fi

  "$EDITOR" /tmp/note

  note="$(cat /tmp/note)"
  rm /tmp/note

  [ -z "$pass" ] && {
    echo "Password is unset - exiting!"
    exit
  }

  echo "$note" | openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -salt -pass pass:"$pass" > "$file"
}

_list_notes () {
  for file in "$HOME/Documents/noted"/*; do
    [ -e "$file" ] && echo "$file" | sed "s:$HOME/Documents/noted/::g; s:.bin::g"
  done
}

_help () {
  echo "noted.sh - Script to create AES-encrypted notes, written in POSIX sh"
  echo "Usage: ./noted.sh OPTIONS"
  echo ""
  echo "OPTIONS"
  echo " -h, --help        Prints this message"
  echo " -f, --file FILE   Creates a new note with the name FILE at ~/Documents/noted/FILE.bin"
  echo " -r, --read FILE   Decrypts and prints to stdout the note at ~/Documents/noted/FILE.bin"
  echo " -d, --delete FILE Deletes the encrypted note at ~/Documents/noted/FILE.bin"
  echo " -e, --edit FILE   Edits the contents of the note at ~/Documents/noted/FILE.bin"
  echo " -l, --list        Lists all notes at ~/Documents/noted/"
}

_main () {
  [ -z "$EDITOR" ] && {
    echo "EDITOR is unset - exiting!"
  }

  [ ! -d "$HOME/Documents/noted" ] && {
    _do_init
  }

  case "$1" in
    "-h"|"--help") _help ;;
    "-f"|"--file") _do_create "$2" ;;
    "-r"|"--read") _do_decrypt "$2" ;;
    "-d"|"--delete") _do_delete "$2" ;;
    "-e"|"--edit") _do_edit "$2" ;;
    "-l"|"--list") _list_notes ;;
    *) echo "Invalid usage" && _help ;;
  esac
}

_main "$1" "$2"
