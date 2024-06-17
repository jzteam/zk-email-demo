#!/bin/bash

# 编译 circom: circom -l node_modules MyTest.circom --wasm --r1cs --sym --c -o target/RegexEmail
circom -l node_modules circuits/RegexEmail.circom --wasm --r1cs --sym -o target/RegexEmail
wait

# 生成 zkey 和 vkey
# snarkjs groth16 setup MyTest.r1cs pot19_final.ptau MyTest_0000.zkey
# snarkjs zkey contribute MyTest_0000.zkey MyTest.zkey --name="1st Contributor Name" -v < Test123456
# snarkjs zkey export verificationkey MyTest.zkey vkey.json
snarkjs groth16 setup target/RegexEmail/RegexEmail.r1cs powersOfTau19_final.ptau target/RegexEmail/RegexEmail_0000.zkey
wait
echo "test" | snarkjs zkey contribute target/RegexEmail/RegexEmail_0000.zkey target/RegexEmail/RegexEmail_final.zkey
wait
snarkjs zkey export verificationkey target/RegexEmail/RegexEmail_final.zkey target/RegexEmail/RegexEmail_vkey.json
wait

# 准备 input.json
mv ./regex-email-input.json ./target/RegexEmail/input.json

# 生成 wtns
node target/RegexEmail/RegexEmail_js/generate_witness.js target/RegexEmail/RegexEmail_js/RegexEmail.wasm target/RegexEmail/input.json target/RegexEmail/witness.wtns
wait

# 生成 proof
snarkjs groth16 prove target/RegexEmail/RegexEmail_final.zkey target/RegexEmail/witness.wtns target/RegexEmail/proof.json target/RegexEmail/public.json
wait

# 验证 proof
snarkjs groth16 verify target/RegexEmail/RegexEmail_vkey.json target/RegexEmail/public.json target/RegexEmail/proof.json
wait
