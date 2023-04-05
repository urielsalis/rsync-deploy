#!/bin/sh
set -eu

SSHPATH="$HOME/.ssh"
rm -rf "$SSHPATH" 
mkdir "$SSHPATH"
echo "$DEPLOY_KEY" > "$SSHPATH/key"
chmod 600 "$SSHPATH/key"
SERVER_DEPLOY_STRING="$USERNAME@$SERVER_IP:$SERVER_DESTINATION"

echo Login to Azure
az config set extension.use_dynamic_install=yes_without_prompt
az login --service-principal -u $CLIENT_ID -p $CLIENT_SECRET --tenant $TENANT_ID

echo Opening tunnel
az network bastion tunnel --port 50022 --resource-port 22 --target-resource-id $RESOURCE_ID --name $BASTION_NAME --resource-group $RESOURCE_GROUP &
# Wait for bastion tunnel port to open
{
  while ! nc -z localhost 50022; do
    sleep 1
  done
  sleep 1
} 2>/dev/null

echo Synchronizing
sh -c "rsync $ARGS -e 'ssh -i $SSHPATH/key -o StrictHostKeyChecking=no -p $SERVER_PORT' $GITHUB_WORKSPACE/$FOLDER $SERVER_DEPLOY_STRING"
