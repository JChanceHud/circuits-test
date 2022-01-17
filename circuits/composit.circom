pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template Composit () {
  signal input secret;
  signal input lastNonce;
  signal input nonce;
  signal input operation;
  signal output compositHash;

  nonce - lastNonce === 1;

  component p1 = Poseidon(1);
  p1.inputs[0] <== secret;
  var secretHash = p1.out;

  component p2 = Poseidon(3);
  p2.inputs[0] <== secretHash;
  p2.inputs[1] <== nonce;
  p2.inputs[2] <== operation;

  compositHash <== p2.out;
}

component main = Composit();
