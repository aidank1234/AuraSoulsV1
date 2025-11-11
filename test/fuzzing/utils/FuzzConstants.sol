// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FuzzConstants {
    // Protocol fee destinations
    address internal constant PROTOCOL_FEE_DEST = address(0xFEE1);
    address internal constant LP_BUCKET_FEE_DEST = address(0xFEE2);
    
    // Default fee percentages (out of 1 ether = 100%)
    uint256 internal constant DEFAULT_PROTOCOL_FEE = 0.05 ether; // 5%
    uint256 internal constant DEFAULT_SUBJECT_FEE = 0.05 ether; // 5%
    uint256 internal constant DEFAULT_LP_BUCKET_FEE = 0.05 ether; // 5%
}
