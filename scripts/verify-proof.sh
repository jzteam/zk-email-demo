#!/bin/bash

# 验证 proof
snarkjs groth16 verify target/TestZkEmail/TestZkEmail_vkey.json target/TestZkEmail/public.json target/TestZkEmail/proof.json
wait
