#!/usr/bin/env sh

if ! command -v realpath 1> /dev/null
then
    echo "The command 'realpath' could not be found"
    echo "Please install it using 'brew install coreutils'"
    echo "Or a package manager of your choice..."
    exit 1
fi

# follow the symlink created by npx
INIT_PACKAGE_BIN_REAL_PATH=$(realpath "$0")
INIT_PACKAGE_DIR=$(dirname "$INIT_PACKAGE_BIN_REAL_PATH")

NEW_PACKAGE_NAME=$(basename "$PWD")

log() {
  echo
  echo "*** $1"
}

create_new_gh_repo() {
  echo "Should this repo be private?"
  select yn in "Yes" "No"; do
    case $yn in
      Yes ) gh repo create --private; break;;
      No ) gh repo create --public; break;;
    esac
  done
}

push_if_origin_defined() {
  git config remote.origin.url 2> /dev/null
  if test $? = 0; then
    git push origin "$(git branch --show-current)"
  else
    echo "Origin does not exist. Not pushing to remote..."
  fi
}

write_template() {
  NEW_FILE_NAME=$(head -n 1 "$1")
  TEMPLATE=$(tail -n +3 "$1")
  eval "echo \"${TEMPLATE}\"" > "$PWD/$NEW_FILE_NAME"
}

log "Initializing git repo"
  git init

log "Creating GitHub repo"
  echo "Want to create a GitHub repo?"
  select yn in "Yes" "No"; do
    case $yn in
      Yes ) create_new_gh_repo; break;;
      No ) break;;
    esac
  done

log "Creating package.json"
  npm init --yes 1> /dev/null

log "Writing template files"
  echo "$INIT_PACKAGE_DIR"
  for FILE in "$INIT_PACKAGE_DIR"/templates/*
  do
    write_template "$FILE"
  done

log "Making initial commit"
  git add .
  git commit -m "Initial commit"
  push_if_origin_defined
