.PHONY: require-% init plan apply refresh plan-destroy destroy ssh status provision-%

PILOSA_PRIVATE_IP=$(shell terraform output -json | jq -r ".private_ips.value[$(N)]")
PILOSA_PUBLIC_IP=$(shell terraform output -json | jq -r ".public_ips.value[$(N)]")
PILOSA_GOSSIP_SEEDS=$(shell terraform output -json | jq -c "[.private_ips.value[] | . + \":14000\"]")
PILOSA_PUBLIC_IPS=$(shell terraform output -json | jq -r ".public_ips.value|join(\",\")")
AGENT_IP=$(shell terraform output -json | jq -r ".agent_ips.value[$(N)]")
AGENT_IPS=$(shell terraform output -json | jq -r ".agent_ips.value|join(\",\")")
PILOSA_VERSION=master
# Don't change this directly. Use "terraform workspace select" 
WORKSPACE=$(shell terraform workspace show)
N=0
CMD=
VAR_FILE=$(WORKSPACE).tfvars
TF_ARGS=-var-file=$(VAR_FILE)
ANSIBLE_ARGS=
ANSIBLE_ARGS_FINAL=-e version=$(PILOSA_VERSION) -e gossip_seeds='$(PILOSA_GOSSIP_SEEDS)' $(ANSIBLE_ARGS)
export ANSIBLE_HOST_KEY_CHECKING=false

# Halt the process if the command is not present (currently all checked commands have valid "--version" subcommands)
require-%:
	@$* --version &> /dev/null

init: require-terraform
	terraform init

plan: require-terraform
	terraform plan $(TF_ARGS)

apply: require-terraform
	terraform apply $(TF_ARGS)

plan-destroy: require-terraform
	terraform plan -destroy $(TF_ARGS)

destroy: require-terraform
	terraform destroy $(TF_ARGS)

output: require-terraform
	terraform output

ssh: require-terraform require-jq
	ssh -o UserKnownHostsFile=/dev/null \
		-o StrictHostKeyChecking=no \
		-l ubuntu \
		$(PILOSA_PUBLIC_IP) $(CMD)

status: require-terraform require-jq
	$(MAKE) ssh CMD="curl $(PILOSA_PRIVATE_IP):10101/status|jq"

provision-%: require-jq require-terraform require-ansible
	ansible-playbook \
		-e 'ansible_python_interpreter=/usr/bin/python3' \
		-i $(PILOSA_PUBLIC_IPS), \
		$(ANSIBLE_ARGS_FINAL) ../ansible/$*.yml

provisiona-%: require-jq require-terraform require-ansible
	ansible-playbook \
		-e 'ansible_python_interpreter=/usr/bin/python3' \
		-i $(AGENT_IPS), \
		$(ANSIBLE_ARGS_FINAL) ../ansible/$*.yml

ssha: require-terraform require-jq
	ssh -o UserKnownHostsFile=/dev/null \
		-o StrictHostKeyChecking=no \
		-l ubuntu \
		$(AGENT_IP) $(CMD)

blah:
	echo $(PILOSA_PUBLIC_IPS)

runa:
	$(MAKE) run HOSTS=$(AGENT_IPS),

runp:
	$(MAKE) run HOSTS=$(PILOSA_PUBLIC_IPS),

run:
	ansible \
		all \
		-i $(HOSTS) \
		-e 'ansible_python_interpreter=/usr/bin/python3' \
		-u ubuntu \
		-m shell \
		-a "$(CMD)"
