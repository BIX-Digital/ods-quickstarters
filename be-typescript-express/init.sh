#!/usr/bin/env bash
set -eux

# Get directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

while [[ "$#" > 0 ]]; do case $1 in
  -p=*|--project=*) PROJECT="${1#*=}";;
  -p|--project) PROJECT="$2"; shift;;

  -c=*|--component=*) COMPONENT="${1#*=}";;
  -c|--component) COMPONENT="$2"; shift;;

  -g=*|--group=*) GROUP="${1#*=}";;
  -g|--group) GROUP="$2"; shift;;

  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done



mkdir $COMPONENT
cd $COMPONENT

echo "generate project"
yo --no-insight node-express-typescript




echo "fix nexus repo path"
repo_path=$(echo "$GROUP" | tr . /)
sed -i.bak "s|org/opendevstack/projectId|$repo_path|g" $SCRIPT_DIR/files/docker/Dockerfile
rm $SCRIPT_DIR/files/docker/Dockerfile.bak

echo "copy custom files & fixes from quickstart to generated project"
cp -rv $SCRIPT_DIR/files/. .
cp -r $SCRIPT_DIR/fix/. src/

echo "adding directories 'lib' and 'docker' to nyc exlude list to fix coverage test issue"
sed -i 's/--reporter=text/--exclude=\\"docker\\" --exclude=\\"lib\\" --reporter=text/g' package.json
