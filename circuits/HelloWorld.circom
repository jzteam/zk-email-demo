pragma circom 2.1.5;

template HelloWorld() {
   signal input in1;
   signal input in2;
   signal output out <== in1 * in2;
}


component main { public [ in1 ] } = HelloWorld();
