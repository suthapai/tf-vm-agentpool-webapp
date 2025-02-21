



# Commands to install the self-hosted agent
curl -o vsts-agent-linux-x64.tar.gz https://vstsagentpackage.azureedge.net/agent/3.234.0/vsts-agent-linux-x64-3.234.0.tar.gz
mkdir myagent
tar zxvf vsts-agent-linux-x64.tar.gz -C myagent
chmod -R 777 myagent
# Configuration of the self-hosted agent
cd myagent
./config.sh --unattended --url your organization url --auth pat --token your token created --pool Default --agent aksagent --acceptTeeEula
# Start the agent service
sudo ./svc.sh install
sudo ./svc.sh start
exit 0
