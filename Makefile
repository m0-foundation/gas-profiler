# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

profile ?=default

# dapp deps
update:; forge update

# Common tasks
tests:
	MAINNET_RPC_URL=$(MAINNET_RPC_URL) ./test.sh -p $(profile)

coverage:
	FOUNDRY_PROFILE=$(profile) MAINNET_RPC_URL=$(MAINNET_RPC_URL) forge coverage --no-match-path 'test/in*/**/*.sol' --report lcov && lcov --extract lcov.info --rc lcov_branch_coverage=1 --rc derive_function_end_line=0 -o lcov.info 'src/*' && genhtml lcov.info --rc branch_coverage=1 --rc derive_function_end_line=0 -o coverage

clean:
	forge clean && rm -rf ./abi && rm -rf ./bytecode && rm -rf ./types
