#!/usr/bin/env sh

# follow the symlink created by npx
INIT_PACKAGE_BIN_REAL_PATH=$(realpath "$0")
INIT_PACKAGE_DIR=$(dirname "$INIT_PACKAGE_BIN_REAL_PATH")

NEW_PACKAGE_NAME=$(basename "$PWD")

log() {
  echo
  echo "*** $1"
}

check_if_defined() {
  if [ -z "$1" ]; then
    echo "Please define $1 env var...";
    exit 1
  fi
}

create_new_gh_repo() {
  check_if_defined "GH_USERNAME"
  curl -u "$GH_USERNAME:$GH_ACCESS_TOKEN" https://api.github.com/user/repos -d "{\"name\":\"$NEW_PACKAGE_NAME\"}" 1> /dev/null
  git remote add origin "git@github.com:$GH_USERNAME/$NEW_PACKAGE_NAME.git"
  git checkout -b main
  git commit --allow-empty -m "Push main"
  git push origin main
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

log "Copying config files"
  cp -r "$INIT_PACKAGE_DIR/templates/."[a-zA-Z0-9]* "$INIT_PACKAGE_DIR/templates/"* "$PWD"

log "Creating Code of Conduct"
  "$INIT_PACKAGE_DIR/node_modules/.bin/conduct"

log "Making initial commit"
  git add .
  git commit -m "Initial commit"