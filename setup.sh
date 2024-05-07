#!/bin/bash

NUM_CONTAINERS=5
CONTAINER_PREFIX=cpp_dev_

docker volume create projects
docker volume create dump

# generate devcontainer.json
for ((i=1; i<=NUM_CONTAINERS; i++)); do
    mkdir -p container$i

    CONTAINER_CONFIG_FILE=container$i/.devcontainer.json

    echo '' > ${CONTAINER_CONFIG_FILE}
    echo '// For format details, see https://aka.ms/devcontainer.json. For config options, see the README at:' >> ${CONTAINER_CONFIG_FILE}
    echo '// https://github.com/microsoft/vscode-dev-containers/tree/v0.241.1/containers/docker-from-docker-compose' >> ${CONTAINER_CONFIG_FILE}
    echo '{' >> ${CONTAINER_CONFIG_FILE}
    echo "	\"name\": \"container-$i\"," >> ${CONTAINER_CONFIG_FILE}
    echo '	"dockerComposeFile": "../docker-compose.yml",' >> ${CONTAINER_CONFIG_FILE}
    echo "	\"service\": \"${CONTAINER_PREFIX}$i\"," >> ${CONTAINER_CONFIG_FILE}
    echo "	\"workspaceFolder\": \"/workspace/container$i\"," >> ${CONTAINER_CONFIG_FILE}
    echo '	// Use this environment variable if you need to bind mount your local source code into a new container.' >> ${CONTAINER_CONFIG_FILE}
    echo '	"remoteEnv": {' >> ${CONTAINER_CONFIG_FILE}
    echo '		"LOCAL_WORKSPACE_FOLDER": "${localWorkspaceFolder}"' >> ${CONTAINER_CONFIG_FILE}
    echo '	},' >> ${CONTAINER_CONFIG_FILE}
    echo '	"containerEnv": {' >> ${CONTAINER_CONFIG_FILE}
    echo '		"ASAN_OPTIONS": "abort_on_error=1:disable_coredump=0:unmap_shadow_on_exit=1"' >> ${CONTAINER_CONFIG_FILE}
    echo '	},' >> ${CONTAINER_CONFIG_FILE}
    echo '	// Configure tool-specific properties.' >> ${CONTAINER_CONFIG_FILE}
    echo '	"customizations": {' >> ${CONTAINER_CONFIG_FILE}
    echo '		// Configure properties specific to VS Code.' >> ${CONTAINER_CONFIG_FILE}
    echo '		"vscode": {' >> ${CONTAINER_CONFIG_FILE}
    echo '			// Add the IDs of extensions you want installed when the container is created.' >> ${CONTAINER_CONFIG_FILE}
    echo '			"extensions": [' >> ${CONTAINER_CONFIG_FILE}
    echo '				"ms-vscode.cpptools",' >> ${CONTAINER_CONFIG_FILE}
    echo '				"ms-vscode.cmake-tools",' >> ${CONTAINER_CONFIG_FILE}
    echo '				"visualstudioexptteam.vscodeintel",' >> ${CONTAINER_CONFIG_FILE}
    echo '				"eamodio.gitlens",' >> ${CONTAINER_CONFIG_FILE}
    echo '				"matepek.vscode-catch2-test-adapter",' >> ${CONTAINER_CONFIG_FILE}
    echo '				"spmeesseman.vscode-taskexplorer",' >> ${CONTAINER_CONFIG_FILE}
    echo '				"urosvujosevic.explorer-manager",' >> ${CONTAINER_CONFIG_FILE}
    echo '				"mhutchie.git-graph",' >> ${CONTAINER_CONFIG_FILE}
    echo '				"ms-python.python",' >> ${CONTAINER_CONFIG_FILE}
    echo '				"github.copilot",' >> ${CONTAINER_CONFIG_FILE}
    echo '				"twxs.cmake",' >> ${CONTAINER_CONFIG_FILE}
    echo '				"github.vscode-pull-request-github",' >> ${CONTAINER_CONFIG_FILE}
    echo '				"llvm-vs-code-extensions.vscode-clangd"' >> ${CONTAINER_CONFIG_FILE}
    echo '				"liangqin.quick-notes"' >> ${CONTAINER_CONFIG_FILE}
    echo '			]' >> ${CONTAINER_CONFIG_FILE}
    echo '		}' >> ${CONTAINER_CONFIG_FILE}
    echo '	},' >> ${CONTAINER_CONFIG_FILE}
    echo '	"shutdownAction": "none",' >> ${CONTAINER_CONFIG_FILE}
    echo '	// Use 'forwardPorts' to make a list of ports inside the container available locally.' >> ${CONTAINER_CONFIG_FILE}
    echo '	// "forwardPorts": [],' >> ${CONTAINER_CONFIG_FILE}
    echo '	// Use 'postCreateCommand' to run commands after the container is created.' >> ${CONTAINER_CONFIG_FILE}
    echo '	"postCreateCommand": [' >> ${CONTAINER_CONFIG_FILE}
    echo '		"python3 -m pip install taospy numpy fabric2 psutil pandas"' >> ${CONTAINER_CONFIG_FILE}
    echo '	],' >> ${CONTAINER_CONFIG_FILE}
    echo '	// Comment out to connect as root instead. More info: https://aka.ms/vscode-remote/containers/non-root.' >> ${CONTAINER_CONFIG_FILE}
    echo '	"remoteUser": "root"' >> ${CONTAINER_CONFIG_FILE}
    echo '}' >> ${CONTAINER_CONFIG_FILE}
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
    echo "      - dump:/mnt/wslg/dumps/" >> docker-compose.yml
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
echo "  dump:" >> docker-compose.yml
echo "    external: true" >> docker-compose.yml
echo "  # https://gist.github.com/devops-school/471f0d11c49142c61b3fae5eb91caf0f" >> docker-compose.yml
echo "  # docker volume create --driver local --opt type=tmpfs --opt device=tmpfs --opt o=size=1000m,uid=1000 limitd" >> docker-compose.yml
echo "  # limitd:" >> docker-compose.yml
echo "  #   external: true" >> docker-compose.yml