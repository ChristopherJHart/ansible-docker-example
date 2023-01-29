FROM python:3.10

# Copy Python dependency file inside container, then install dependencies using
# pip.
COPY requirements.txt .

RUN apt -y update && \
    apt -y install sshpass && \
    python -m pip install --upgrade pip && \
    python -m pip install -r requirements.txt && \
    apt -y autoremove && \
    rm -rf /var/lib/apt/lists/*

# Copy Ansible dependency file inside container, then install dependencies
# using ansible-galaxy
COPY requirements.yaml .

RUN ansible-galaxy collection install -r requirements.yaml

# Copy inventory files to the default locations Ansible expects them to be in
COPY inventory.yaml /etc/ansible/hosts
COPY group_vars/ /etc/ansible/group_vars
COPY host_vars/ /etc/ansible/host_vars

# Copy Ansible configuration file to the default location Ansible expects it to
# be in.
COPY ansible.cfg /etc/ansible/ansible.cfg

# Copy site.yaml playbook that orchestrates Ansible automation, as well as all
# roles.
COPY site.yaml .
COPY roles/ .

# When Docker container is executed, execute the site.yaml Ansible playbook.
CMD ["ansible-playbook", "site.yaml"]
