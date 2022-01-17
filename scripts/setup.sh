#!/bin/sh

set -e

# exit if circom is not present
which circom > /dev/null

BASEDIR=$(dirname $(readlink -f "$0"))
WORKDIR=$(mktemp -d)
CIRCUIT_NAME=auth

# compile the circuits
circom $BASEDIR/../circuits/${CIRCUIT_NAME}.circom --r1cs --wasm --sym --c -o $WORKDIR

# generate a witness
node $WORKDIR/${CIRCUIT_NAME}_js/generate_witness.js $WORKDIR/${CIRCUIT_NAME}_js/${CIRCUIT_NAME}.wasm $BASEDIR/../circuits/${CIRCUIT_NAME}.json $WORKDIR/witness.wtns

# run an insecure powers of tau to $CIRCUIT_NAME the zk proof
snarkjs powersoftau new bn128 12 $WORKDIR/pot12_0000.ptau -v
snarkjs powersoftau contribute $WORKDIR/pot12_0000.ptau $WORKDIR/pot12_0001.ptau --name="Test Contributor" -v -e="entropyasdklasd"

snarkjs powersoftau prepare phase2 $WORKDIR/pot12_0001.ptau $WORKDIR/pot12_final.ptau
snarkjs groth16 setup ${WORKDIR}/${CIRCUIT_NAME}.r1cs $WORKDIR/pot12_final.ptau $WORKDIR/${CIRCUIT_NAME}_0000.zkey
snarkjs zkey contribute $WORKDIR/${CIRCUIT_NAME}_0000.zkey $WORKDIR/${CIRCUIT_NAME}_0001.zkey --name="Test Contributor2" -v -e="entropyaskdflja"
snarkjs zkey export verificationkey $WORKDIR/${CIRCUIT_NAME}_0001.zkey $WORKDIR/verification_key.json

echo "Proving..."
snarkjs groth16 prove $WORKDIR/${CIRCUIT_NAME}_0001.zkey $WORKDIR/witness.wtns $WORKDIR/proof.json $WORKDIR/public.json
snarkjs groth16 verify $WORKDIR/verification_key.json $WORKDIR/public.json $WORKDIR/proof.json
cat $WORKDIR/public.json
