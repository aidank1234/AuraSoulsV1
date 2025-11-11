// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../FuzzSetup.sol";

contract HelperFunctions is FuzzSetup {
    function generateFuzzNumber(
        uint256 _iteration,
        uint256 _seed
    ) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(_iteration * PRIME + _seed)));
    }

    function toString(address _addr) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }
    
    // Helper to get sum of all balances for a subject
    function getSumOfBalances(address subject) internal view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < USERS.length; i++) {
            sum += auraSoulsV1.soulsBalance(subject, USERS[i]);
        }
        // Also check non-user addresses that might hold souls
        sum += auraSoulsV1.soulsBalance(subject, subject);
        return sum;
    }
}
