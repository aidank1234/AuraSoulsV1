// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../FuzzSetup.sol";

/**
 * @title FuzzStructs
 * @notice Centralized location for all parameter structs used in the UniversalFuzzing framework
 */
contract FuzzStructs is FuzzSetup {
    struct BuySoulsParams {
        address soulsSubject;
        uint256 amount;
        uint256 expectedPrice;
        bool shouldRevert;
    }

    struct SellSoulsParams {
        address soulsSubject;
        uint256 amount;
        uint256 expectedPayout;
        bool shouldRevert;
    }

    struct SetFeePercentParams {
        uint256 feePercent;
        uint8 feeType; // 0 = protocol, 1 = subject, 2 = lpBucket
    }
}
