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

# 初始化 zk-email-demo 依赖
npm install -g yarn
rm yarn.lock
yarn add @zk-email/circuits @zk-email/helpers @zk-email/contracts 
wait
yarn add ts-node typescript
wait
npm install -g snarkjs

# 生成 input.json
npx ts-node inputs.ts

# 编译 circom，编译超级慢，特别占内存 128G测试中
# -l 添加一个文件夹到库搜索路径中
# -o 输出到指定文件夹，默认 ./
# --O0 不简化
# --O1 部分简化
# --O2 全部简化
# --verbose 输出编译日志
circom -l node_modules circuits/TestZkEmail.circom -o target --r1cs --wasm --sym --c --O2 --verbose

