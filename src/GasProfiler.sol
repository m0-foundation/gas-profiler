// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.26;

import { VmSafe } from "../lib/forge-std/src/Vm.sol";

abstract contract GasProfiler {
    VmSafe private immutable _vm;

    mapping(string profileName => uint256 totalGas) private _totalGas;

    string[] private _profileNames;

    constructor(address vm_) {
        _vm = VmSafe(vm_);
        _makeDirectory("./gas-profiles");
    }

    function _makeDirectory(string memory directory_) private {
        string[] memory command_ = new string[](3);
        command_[0] = "mkdir";
        command_[1] = "-p";
        command_[2] = directory_;

        _vm.ffi(command_);
    }

    function _profileGasOfLastCall(string memory profileName_) internal {
        uint256 gasUsed = _vm.lastCallGas().gasTotalUsed;

        if ((_totalGas[profileName_] += gasUsed) != 0) {
            _profileNames.push(profileName_);
        }
    }

    function _writeGasProfiles(string memory fileName_) internal {
        for (uint256 index_; index_ < _profileNames.length; ++index_) {
            string memory profileName_ = _profileNames[index_];
            _vm.writeLine(_getFullPath("./gas-profiles", fileName_), _getLine(profileName_, _totalGas[profileName_]));
        }
    }

    function _getFullPath(
        string memory filePath_,
        string memory fileName_
    ) private pure returns (string memory fullPath_) {
        return string(abi.encodePacked(filePath_, "/", fileName_, ".json"));
    }

    function _getLine(string memory profileName_, uint256 value_) private view returns (string memory) {
        return string(abi.encodePacked(profileName_, ": ", _vm.toString(value_)));
    }
}
