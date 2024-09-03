#!/bin/sh
set -eu

SSHPATH="$HOME/.ssh"
rm -rf "$SSHPATH" 
mkdir "$SSHPATH"
echo "$DEPLOY_KEY" > "$SSHPATH/key"
chmod 600 "$SSHPATH/key"
SERVER_DEPLOY_STRING="$USERNAME@$SERVER_IP:$SERVER_DESTINATION"

echo Login to Azure following https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect#set-up-azure-login-action-with-openid-connect-in-github-actions-workflows before calling this!
az config set extension.use_dynamic_install=yes_without_prompt

echo Opening tunnel
az network bastion tunnel --port 50022 --resource-port 22 --target-resource-id $RESOURCE_ID --name $BASTION_NAME --resource-group $RESOURCE_GROUP &

echo Wait for bastion tunnel to open...
az network bastion wait --created --name $BASTION_NAME --resource-group $RESOURCE_GROUP 

echo Synchronizing
sh -c "rsync $ARGS -e 'ssh -i $SSHPATH/key -o StrictHostKeyChecking=no -p $SERVER_PORT' $GITHUB_WORKSPACE/$FOLDER $SERVER_DEPLOY_STRING"
