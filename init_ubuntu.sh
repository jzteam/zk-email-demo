#!/bin/bash

# 安装git
if command -v git &> /dev/null; then
    echo "Git is installed."
else
    echo "Git is not installed. start to install"
    yum install -y git
fi
wait
# 下载项目
if [[  $(pwd)  == *"zk-email-demo"* ]];then
  echo "project exists."
else
    echo "project not exists. start to clone"
    git clone https://github.com/jzteam/zk-email-demo.git
    wait
    cd zk-email-demo
fi
wait

# 安装node
if command -v node -v &> /dev/null; then
  echo "node is installed."
else 
  echo "node is not installed. start to intall"
  if command -v nvm --version &> /dev/null; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
    wait
    source ~/.bashrc
    nvm --version
  fi  
  nvm install 20.10.0
  wait
  nvm use default
  node -v
fi  

# 安装rust
if command -v rustup -V &> /dev/null; then
  echo "rust is installed."
else
  echo "rust is not installed. start to install"
  curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
  wait
  rustup -V
fi

# 安装circom
if comman -v circom --version &> /dev/null; then
  echo "circom is installed."
else
  echo "circom is not installed."
  git clone https://github.com/iden3/circom.git
  wait
  cd circom
  cargo build --release && cargo install --path circom
  wait
  circom --version
fi

