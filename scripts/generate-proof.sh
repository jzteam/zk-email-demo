#!/bin/bash

if [ $(basename $(pwd)) != "zk-email-demo" ];then
    echo "请到项目根目录下执行命令";
    exit 1;
fi

circomName=${1:-TestZkEmail}
powersOfTau=${2:-22}
inputTsPath=${3:-test/hello-world-inputs.ts}
emlPath=${4:-./emls/rawEmailSimple.eml}

# 准备编译文件，zkey 和 vkey
if [ ! -e "./target/${circomName}/${circomName}_js/${circomName}.wasm" ] || [ ! -e "./target/${circomName}/${circomName}_final.zkey" ];then
    echo "wasm 或 zkey 不存在，重新构建"
    ./scripts/rebuild-circom.sh ${circomName} ${powersOfTau} && wait
    if [ $? != 0 ];then
        echo "rebuild-circom 失败，自动退出";
        exit 1;
    fi
fi

# 生成 input.json
echo "开始生成 input.json"
mkdir -p ./target/${circomName} && touch ./target/${circomName}/input.json
ts-node ${inputTsPath} ${emlPath} ./target/${circomName}/input.json && wait
if [ $? != 0 ];then
    echo "使用 ${inputTsPath} 生成 input.json 失败，自动退出";
    exit 1;
fi
echo "使用 ${inputTsPath} 生成 input.json 完成"

# 生成 wtns
echo "开始生成 wtns"
node target/${circomName}/${circomName}_js/generate_witness.js target/${circomName}/${circomName}_js/${circomName}.wasm target/${circomName}/input.json target/${circomName}/witness.wtns && wait
if [ $? != 0 ];then
    echo "生成 wtns 失败，自动退出";
    exit 1;
fi
echo "生成 wtns 完成"

# 生成 proof
echo "开始生成 proof"
snarkjs groth16 prove target/${circomName}/${circomName}_final.zkey target/${circomName}/witness.wtns target/${circomName}/proof.json target/${circomName}/public.json && wait
if [ $? != 0 ];then
    echo "生成 proof 失败，自动退出";
    exit 1;
fi
echo "生成 proof 完成"
