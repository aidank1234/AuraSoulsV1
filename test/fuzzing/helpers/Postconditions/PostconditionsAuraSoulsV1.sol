// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PostconditionsBase.sol";
import "../FuzzStructs.sol";

contract PostconditionsAuraSoulsV1 is FuzzStructs, PostconditionsBase {
    function buySoulsPostconditions(
        bool success,
        bytes memory returnData,
        BuySoulsParams memory params
    ) internal {
        if (success) {
            // Update ghost variables
            _after();
            
            // Check buy-specific invariants
            invariant_BUY_01_supplyIncreases(params.soulsSubject, params.amount);
            invariant_BUY_02_balanceIncreases(params.soulsSubject, currentActor, params.amount);
            invariant_BUY_03_firstSoulRule(params.soulsSubject, currentActor);
            
            // Check global invariants
            onSuccessInvariantsGeneral(returnData);
        } else {
            // Handle failure
            onFailInvariantsGeneral(returnData);
        }
    }

    function sellSoulsPostconditions(
        bool success,
        bytes memory returnData,
        SellSoulsParams memory params
    ) internal {
        if (success) {
            // Update ghost variables
            _after();
            
            // Check sell-specific invariants
            invariant_SELL_01_supplyDecreases(params.soulsSubject, params.amount);
            invariant_SELL_02_balanceDecreases(params.soulsSubject, currentActor, params.amount);
            invariant_SELL_03_cannotSellLastSoul(params.soulsSubject);
            invariant_SELL_04_sufficientBalance(params.soulsSubject, currentActor, params.amount);
            
            // Check global invariants
            onSuccessInvariantsGeneral(returnData);
        } else {
            // Handle failure
            onFailInvariantsGeneral(returnData);
        }
    }

    function setFeePercentPostconditions(
        bool success,
        bytes memory returnData
    ) internal {
        if (success) {
            // Update ghost variables
            _after();
            
            // Check global invariants
            onSuccessInvariantsGeneral(returnData);
        } else {
            // Handle failure
            onFailInvariantsGeneral(returnData);
        }
    }
}
