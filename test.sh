#!/usr/bin/env bash
set -e

if [ -z "$MAINNET_RPC_URL" ]; then
	. .env
fi

gas=false
verbose=false

while getopts d:g:p:t:v flag; do
	case "${flag}" in
	d) directory=${OPTARG} ;;
	g) gas=true ;;
	p) profile=${OPTARG} ;;
	t) test=${OPTARG} ;;
	v) verbose=true ;;
	esac
done

export FOUNDRY_PROFILE=$profile
echo Using profile: $FOUNDRY_PROFILE
echo Higher verbosity: $verbose
echo Gas report: $gas
echo Test Match pattern: $test

if [ "$verbose" = false ]; then
	verbosity="-vv"
else
	verbosity="-vvvv"
fi

if [ "$gas" = false ];
then
    gasReport=""
else
    gasReport="--gas-report"
fi

if [ -z "$test" ]; then
	if [ -z "$directory" ]; then
		forge test --ffi --isolate --match-path "test/*" --fork-url $MAINNET_RPC_URL $gasReport $verbosity
	else
		forge test --ffi --isolate --match-path "$directory/*.t.sol" --fork-url $MAINNET_RPC_URL $gasReport $verbosity
	fi
else
	forge test --ffi --isolate --match-test "$test" --fork-url $MAINNET_RPC_URL $gasReport $verbosity
fi