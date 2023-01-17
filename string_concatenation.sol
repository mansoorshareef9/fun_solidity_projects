//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Concatenator {
    function concatenate(string memory _a, string memory _b)
        public
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(_a, _b);
    }
}
