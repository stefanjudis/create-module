#!/usr/bin/env sh

# follow the symlink created by npx
INIT_PACKAGE_BIN_REAL_PATH=$(realpath "$0")
INIT_PACKAGE_DIR=$(dirname "$INIT_PACKAGE_BIN_REAL_PATH")

NEW_PACKAGE_NAME=$(basename "$PWD")
DEFAULT_BRANCH="main"

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
  git commit --allow-empty -m "Create main"
  git push origin "$DEFAULT_BRANCH"
}

push_if_repo_exists() {
  # https://stackoverflow.com/questions/12170459/check-if-git-remote-exists-before-first-push
  git ls-remote --exit-code origin 2> /dev/null
  if test $? = 0; then
    git push origin "$DEFAULT_BRANCH"
  else
    echo "Origin does not exist. Not pushing to remote..."
  fi
}

write_template() {
  TEMPLATE=$(cat "$INIT_PACKAGE_DIR/templates/$1.txt")
  eval "echo \"${TEMPLATE}\"" > "$PWD/$1.$2"
}

log "Initializing git repo"
  git init
  git checkout -b "$DEFAULT_BRANCH"

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
  cp -r "$INIT_PACKAGE_DIR/files/."[a-zA-Z0-9]* "$INIT_PACKAGE_DIR/files/"* "$PWD"

log "Creating Code of Conduct"
  write_template "CODE-OF-CONDUCT" "md"
  write_template "README" "md"

log "Making initial commit"
  git add .
  git commit -m "Initial commit"
  push_if_repo_exists
