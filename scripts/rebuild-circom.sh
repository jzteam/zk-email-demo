#!/bin/bash
if [ $(basename $(pwd)) != "zk-email-demo" ];then
    echo "请到项目根目录下执行命令";
    exit 1;
fi

circomName=${1:-TestZkEmail}
powersOfTau=${2:-22}

# 编译 circom: circom -l node_modules TestZkEmail.circom --wasm --r1cs --sym --c -o target/TestZkEmail
if [ ! -e ./target/${circomName}/${circomName}.r1cs ]; then
    echo "./target/${circomName}/${circomName}.r1cs 文件不存在，重新编译 circom"
    mkdir -p target/${circomName} && wait
    circom -l node_modules circuits/${circomName}.circom --wasm --r1cs --sym -o target/${circomName} && wait
    if [ $? != 0 ];then
        echo "编译 circom 失败，自动退出";
        exit 1;
    fi
    echo "circom 编译完成"
else
    echo "./target/${circomName}/${circomName}.r1cs 文件已存在，无需重新编译"
fi

# 生成 zkey 和 vkey
# snarkjs groth16 setup MyTest.r1cs pot19_final.ptau MyTest_0000.zkey
# snarkjs zkey contribute MyTest_0000.zkey MyTest.zkey --name="1st Contributor Name" -v < Test123456
# snarkjs zkey export verificationkey MyTest.zkey vkey.json
powersOfTauFileName="powersOfTau28_hez_final_${powersOfTau}.ptau"
if [ ! -e "./${powersOfTauFileName}" ];then
    echo "${powersOfTauFileName} 文件不存在，开始自动下载"
    wget  -P ./ -O ${powersOfTauFileName} -v "https://hermez.s3-eu-west-1.amazonaws.com/${powersOfTauFileName}" && wait
    if [ $? != 0 ];then
        echo "下载 ${powersOfTauFileName} 失败，自动退出";
        exit 1;
    fi
    echo "${powersOfTauFileName} 下载完成"
else
    echo "${powersOfTauFileName} 文件已存在，无需下载"
fi

echo "开始生成 0000.zkey 文件"
snarkjs groth16 setup target/${circomName}/${circomName}.r1cs ./${powersOfTauFileName} target/${circomName}/${circomName}_0000.zkey && wait
if [ $? != 0 ];then
    echo "生成 0000.zkey 失败，自动退出";
    exit 1;
fi
echo "0000.zkey 文件生成完成"
echo "开始生成 final.zkey"
echo "test" | snarkjs zkey contribute target/${circomName}/${circomName}_0000.zkey target/${circomName}/${circomName}_final.zkey && wait
if [ $? != 0 ];then
    echo "生成 final.zkey 失败，自动退出";
    exit 1;
fi
echo "final.zkey 生成完成"
echo "开始生成 vkey.json"
snarkjs zkey export verificationkey target/${circomName}/${circomName}_final.zkey target/${circomName}/${circomName}_vkey.json && wait
if [ $? != 0 ];then
    echo "生成 vkey.json 失败，自动退出";
    exit 1;
fi
echo "源码编译完成，zkey 和 vkey 准备完成"
