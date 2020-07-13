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

create_new_gh_repo() {
  if [ -z "$GH_USERNAME" ] || [ -z "$GH_ACCESS_TOKEN" ]; then
    echo "Please define GH_USERNAME and GH_ACCESS_TOKEN env var";
    exit 1
  fi

  curl -u "$GH_USERNAME:$GH_ACCESS_TOKEN" https://api.github.com/user/repos -d "{\"name\":\"$NEW_PACKAGE_NAME\"}" 1> /dev/null
  git remote add origin "git@github.com:$GH_USERNAME/$NEW_PACKAGE_NAME.git"
  git commit --allow-empty -m "Create main"
  git push origin "$DEFAULT_BRANCH"
}

push_if_repo_exists() {
  git ls-remote --exit-code origin 2> /dev/null
  if test $? = 0; then
    git push origin "$DEFAULT_BRANCH"
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

log "Writing template files"
  echo "$INIT_PACKAGE_DIR"
  for FILE in "$INIT_PACKAGE_DIR"/templates/*
  do
    write_template "$FILE"
  done

log "Making initial commit"
  git add .
  git commit -m "Initial commit"
  push_if_repo_exists
