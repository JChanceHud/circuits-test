pragma circom 2.0.0;

template Test () {
  signal input a;
  signal input b;
  signal output c;

  assert(a != 1);
  assert(b != 1);

  c <== a * b;
}

component main = Test();
