#!/bin/bash
set -xe

PROTOCOL_VERSION=${1:-v29}

# Copy Solidity source files `<contract_name>.sol` from SRC to DST
L1_SOL_SRC_DIR=contracts/l1-contracts/contracts
L1_SOL_DST_DIR=crates/l1_sidecar/src/contracts/sol

mkdir -p $L1_SOL_DST_DIR

l1_sol_contracts=("state-transition/chain-interfaces/IExecutor")

for path in "${l1_sol_contracts[@]}"; do
  directory=$(dirname "$path")
  contract=$(basename "$path")

  if [[ "$contract" == "IExecutor" ]]; then
    version_num=${PROTOCOL_VERSION#v}
    # If version is older than v29, then copy the IExecutor as IExecutorV28 and also change the interface name within the file.
    # After v29 IExecutor interface is incompatible with older IExecutor interface, so it must be copied as such.
    # See https://github.com/matter-labs/anvil-zksync/pull/734
    if [[ "$version_num" =~ ^[0-9]+$ ]] && [[ "$version_num" -lt 29 ]]; then
      cp "$L1_SOL_SRC_DIR/$directory/$contract.sol" "$L1_SOL_DST_DIR/IExecutorV28.sol"
      sed -i 's/interface IExecutor/interface IExecutorV28/g' "$L1_SOL_DST_DIR/IExecutorV28.sol"
      continue
    fi
  fi

  cp "$L1_SOL_SRC_DIR/$directory/$contract.sol" $L1_SOL_DST_DIR
done

# Copy Sol-based JSON artifacts `<contract_name>.json` for L1 contracts
L1_JSON_ABI_SRC_DIR=contracts/l1-contracts/zkout
L1_JSON_ABI_DST_DIR=crates/l1_sidecar/src/contracts/artifacts

mkdir -p $L1_JSON_ABI_DST_DIR

l1_json_contracts=("IZKChain")

for path in "${l1_json_contracts[@]}"; do
  directory=$(dirname "$path")
  contract=$(basename "$path")
  cp "$L1_JSON_ABI_SRC_DIR/$directory/$contract.sol/$contract.json" $L1_JSON_ABI_DST_DIR
done
