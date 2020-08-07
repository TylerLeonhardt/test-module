set -exv

AgentTemp=$(mktemp)
AgentURL=https://vsoagentdownloads.blob.core.windows.net/vsoagent/VSOAgent_linux_3929085.tar.gz
wget --progress=bar:force:noscroll -O $AgentTemp --user-agent vso/1.0 $AgentURL
pwd
mkdir -p bin
tar -xf $AgentTemp -C bin/
rm $AgentTemp
chmod +x bin/codespaces
chmod +x bin/vsls-agent
echo "VSO installed! Just run codespaces start to set up your machine's environment"