#!/bin/bash

# 编译 circom: circom -l node_modules TestZkEmail.circom --wasm --r1cs --sym --c -o target/TestZkEmail
circom -l node_modules circuits/TestZkEmail.circom --wasm --r1cs --sym -o target/TestZkEmail
wait

# 生成 zkey 和 vkey
# snarkjs groth16 setup MyTest.r1cs pot19_final.ptau MyTest_0000.zkey
# snarkjs zkey contribute MyTest_0000.zkey MyTest.zkey --name="1st Contributor Name" -v < Test123456
# snarkjs zkey export verificationkey MyTest.zkey vkey.json
snarkjs groth16 setup target/TestZkEmail/TestZkEmail.r1cs ./powersOfTau19_final.ptau target/TestZkEmail/TestZkEmail_0000.zkey
wait
echo "test" | snarkjs zkey contribute target/TestZkEmail/TestZkEmail_0000.zkey target/TestZkEmail/TestZkEmail_final.zkey
wait
snarkjs zkey export verificationkey target/TestZkEmail/TestZkEmail_final.zkey target/TestZkEmail/TestZkEmail_vkey.json
wait

# 生成 input.json
npx ts-node test/inputs.ts
cp ./target/input.json ./target/TestZkEmail/input.json

# 生成 wtns
node target/TestZkEmail/TestZkEmail_js/generate_witness.js target/TestZkEmail/TestZkEmail_js/TestZkEmail.wasm target/TestZkEmail/input.json target/TestZkEmail/witness.wtns
wait

# 生成 proof
snarkjs groth16 prove target/TestZkEmail/TestZkEmail_final.zkey target/TestZkEmail/witness.wtns target/TestZkEmail/proof.json target/TestZkEmail/public.json
wait

# 验证 proof
snarkjs groth16 verify target/TestZkEmail/TestZkEmail_vkey.json target/TestZkEmail/public.json target/TestZkEmail/proof.json
wait
