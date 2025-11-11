// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../../properties/Properties.sol";

contract PostconditionsBase is Properties {
    function onSuccessInvariantsGeneral(bytes memory returnData) internal {
        // Check all global invariants
        invariant_GLOB_01_conservationOfSouls();
        invariant_GLOB_02_supplyNeverNegative();
        invariant_GLOB_03_feePercentsBounded();
        invariant_GLOB_04_creatorEarningsNeverDecrease();
        invariant_GLOB_05_feeDestinationsNeverDecrease();
        
        // Note: Logical coverage disabled by default in FuzzStorageVariables
    }

    function onFailInvariantsGeneral(bytes memory returnData) internal {
        invariant_ERR(returnData);
    }
}
