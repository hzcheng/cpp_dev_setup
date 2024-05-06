#!/bin/bash

NUM_CONTAINERS=3
CONTAINER_PREFIX=cpp_dev_

# generate devcontainer.json
for ((i=1; i<=NUM_CONTAINERS; i++)); do
    mkdir -p container$i
    echo '' > container$i/devcontainer.json
    echo '// For format details, see https://aka.ms/devcontainer.json. For config options, see the README at:' >> container$i/devcontainer.json
    echo '// https://github.com/microsoft/vscode-dev-containers/tree/v0.241.1/containers/docker-from-docker-compose' >> container$i/devcontainer.json
    echo '{' >> container$i/devcontainer.json
    echo "	\"name\": \"${CONTAINER_PREFIX}-$i\"," >> container$i/devcontainer.json
    echo '	"dockerComposeFile": "../docker-compose.yml",' >> container$i/devcontainer.json
    echo "	\"service\": \"${CONTAINER_PREFIX}$i\"," >> container$i/devcontainer.json
    echo "	\"workspaceFolder\": \"/workspace/container$i\"," >> container$i/devcontainer.json
    echo '	// Use this environment variable if you need to bind mount your local source code into a new container.' >> container$i/devcontainer.json
    echo '	"remoteEnv": {' >> container$i/devcontainer.json
    echo '		"LOCAL_WORKSPACE_FOLDER": "${localWorkspaceFolder}"' >> container$i/devcontainer.json
    echo '	},' >> container$i/devcontainer.json
    echo '	// Configure tool-specific properties.' >> container$i/devcontainer.json
    echo '	"customizations": {' >> container$i/devcontainer.json
    echo '		// Configure properties specific to VS Code.' >> container$i/devcontainer.json
    echo '		"vscode": {' >> container$i/devcontainer.json
    echo '			// Add the IDs of extensions you want installed when the container is created.' >> container$i/devcontainer.json
    echo '			"extensions": [' >> container$i/devcontainer.json
    echo '				"ms-vscode.cpptools",' >> container$i/devcontainer.json
    echo '				"ms-vscode.cmake-tools",' >> container$i/devcontainer.json
    echo '				"visualstudioexptteam.vscodeintel",' >> container$i/devcontainer.json
    echo '				"eamodio.gitlens",' >> container$i/devcontainer.json
    echo '				"matepek.vscode-catch2-test-adapter",' >> container$i/devcontainer.json
    echo '				"spmeesseman.vscode-taskexplorer",' >> container$i/devcontainer.json
    echo '				"urosvujosevic.explorer-manager",' >> container$i/devcontainer.json
    echo '				"mhutchie.git-graph",' >> container$i/devcontainer.json
    echo '				"ms-python.python",' >> container$i/devcontainer.json
    echo '				"github.copilot",' >> container$i/devcontainer.json
    echo '				"twxs.cmake",' >> container$i/devcontainer.json
    echo '				"github.vscode-pull-request-github",' >> container$i/devcontainer.json
    echo '				"llvm-vs-code-extensions.vscode-clangd"' >> container$i/devcontainer.json
    echo '			]' >> container$i/devcontainer.json
    echo '		}' >> container$i/devcontainer.json
    echo '	},' >> container$i/devcontainer.json
    echo '	"shutdownAction": "none",' >> container$i/devcontainer.json
    echo '	// Use 'forwardPorts' to make a list of ports inside the container available locally.' >> container$i/devcontainer.json
    echo '	// "forwardPorts": [],' >> container$i/devcontainer.json
    echo '	// Use 'postCreateCommand' to run commands after the container is created.' >> container$i/devcontainer.json
    echo '	"postCreateCommand": [' >> container$i/devcontainer.json
    echo '		"python3 -m pip install taospy numpy fabric2 psutil pandas"' >> container$i/devcontainer.json
    echo '	],' >> container$i/devcontainer.json
    echo '	// Comment out to connect as root instead. More info: https://aka.ms/vscode-remote/containers/non-root.' >> container$i/devcontainer.json
    echo '	"remoteUser": "root"' >> container$i/devcontainer.json
    echo '}' >> container$i/devcontainer.json
done

# generate docker-compose.yml
echo "version: '3.8'" > docker-compose.yml
echo "" >> docker-compose.yml
echo "services:" >> docker-compose.yml
for ((i=1; i<=NUM_CONTAINERS; i++)); do
    echo "  $CONTAINER_PREFIX$i:" >> docker-compose.yml
    echo "    image: hzcheng/hz-cpp-dev" >> docker-compose.yml
    echo "    build:" >> docker-compose.yml
    echo "      context: ." >> docker-compose.yml
    echo "      dockerfile: Dockerfile" >> docker-compose.yml
    echo "    ulimits:" >> docker-compose.yml
    echo "      core:" >> docker-compose.yml
    echo "        soft: -1" >> docker-compose.yml
    echo "        hard: -1" >> docker-compose.yml
    echo "    tty: true" >> docker-compose.yml
    echo "    container_name: $CONTAINER_PREFIX$i" >> docker-compose.yml
    echo "    volumes:" >> docker-compose.yml
    echo "      # Forwards the local Docker socket to the container." >> docker-compose.yml
    echo "      - /var/run/docker.sock:/var/run/docker-host.sock" >> docker-compose.yml
    echo "      # Update this to wherever you want VS Code to mount the folder of your project" >> docker-compose.yml
    echo "      - .:/workspace:cached" >> docker-compose.yml
    echo "      # Project volume" >> docker-compose.yml
    echo "      - projects:/root/workspace/" >> docker-compose.yml
    echo "    # Overrides default command so things don't shut down after the process ends." >> docker-compose.yml
    echo "    # entrypoint: /usr/local/share/docker-init.sh" >> docker-compose.yml
    echo "    command: bash" >> docker-compose.yml
    echo "    # Uncomment the next four lines if you will use a ptrace-based debuggers like C++, Go, and Rust." >> docker-compose.yml
    echo "    cap_add:" >> docker-compose.yml
    echo "      - SYS_PTRACE" >> docker-compose.yml
    echo "      - SYS_ADMIN" >> docker-compose.yml
    echo "    security_opt:" >> docker-compose.yml
    echo "      - seccomp:unconfined" >> docker-compose.yml
    echo "    # Uncomment the next line to use a non-root user for all processes." >> docker-compose.yml
    echo "    # user: root" >> docker-compose.yml
    echo "    # Use "forwardPorts" in **devcontainer.json** to forward an app port locally. " >> docker-compose.yml
    echo "    # (Adding the "ports" property to this file will not forward from a Codespace.)" >> docker-compose.yml
done
echo "volumes:" >> docker-compose.yml
echo "  projects:" >> docker-compose.yml
echo "    external: true" >> docker-compose.yml
echo "  # https://gist.github.com/devops-school/471f0d11c49142c61b3fae5eb91caf0f" >> docker-compose.yml
echo "  # docker volume create --driver local --opt type=tmpfs --opt device=tmpfs --opt o=size=1000m,uid=1000 limitd" >> docker-compose.yml
echo "  # limitd:" >> docker-compose.yml
echo "  #   external: true" >> docker-compose.yml