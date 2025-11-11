// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Properties_ERR.sol";

contract Properties is Properties_ERR {
    // ==============================================================
    // Global Properties (GLOB) - Must hold after EVERY operation
    // ==============================================================

    function invariant_GLOB_01_conservationOfSouls() internal view {
        // For each subject, sum of all holder balances must equal total supply
        for (uint256 i = 0; i < SOUL_SUBJECTS.length; i++) {
            address subject = SOUL_SUBJECTS[i];
            uint256 supply = states[1].subjectStates[subject].soulsSupply;
            uint256 totalBalances = states[1].subjectStates[subject].totalBalances;
            
            fl.eq(
                supply,
                totalBalances,
                "GLOB_01: Sum of balances != supply for subject"
            );
        }
    }

    function invariant_GLOB_02_supplyNeverNegative() internal view {
        // Total supply must always be >= 0 (trivially true for uint256, but captures supply must be valid)
        for (uint256 i = 0; i < SOUL_SUBJECTS.length; i++) {
            address subject = SOUL_SUBJECTS[i];
            uint256 supply = states[1].subjectStates[subject].soulsSupply;
            
            // If supply > 0, it must be at least 1
            if (supply > 0) {
                fl.gte(
                    supply,
                    1,
                    "GLOB_02: Supply must be at least 1 if non-zero"
                );
            }
        }
    }

    function invariant_GLOB_03_feePercentsBounded() internal view {
        // All fee percents must be <= 100% (1 ether)
        fl.lte(
            auraSoulsV1.protocolFeePercent(),
            1 ether,
            "GLOB_03: Protocol fee > 100%"
        );
        fl.lte(
            auraSoulsV1.subjectFeePercent(),
            1 ether,
            "GLOB_03: Subject fee > 100%"
        );
        fl.lte(
            auraSoulsV1.lpBucketFeePercent(),
            1 ether,
            "GLOB_03: LP bucket fee > 100%"
        );
    }

    function invariant_GLOB_04_creatorEarningsNeverDecrease() internal view {
        // Creator earnings should only increase, never decrease
        for (uint256 i = 0; i < SOUL_SUBJECTS.length; i++) {
            address subject = SOUL_SUBJECTS[i];
            uint256 earningsBefore = states[0].subjectStates[subject].creatorEarnings;
            uint256 earningsAfter = states[1].subjectStates[subject].creatorEarnings;
            
            fl.gte(
                earningsAfter,
                earningsBefore,
                "GLOB_04: Creator earnings decreased"
            );
        }
    }

    function invariant_GLOB_05_feeDestinationsNeverDecrease() internal view {
        // Fee destination balances should only increase (they receive fees)
        fl.gte(
            states[1].protocolFeeDestBalance,
            states[0].protocolFeeDestBalance,
            "GLOB_05: Protocol fee destination balance decreased"
        );
        fl.gte(
            states[1].lpBucketFeeDestBalance,
            states[0].lpBucketFeeDestBalance,
            "GLOB_05: LP bucket fee destination balance decreased"
        );
    }

    // ==============================================================
    // Buy-Specific Invariants (BUY)
    // ==============================================================

    function invariant_BUY_01_supplyIncreases(
        address subject,
        uint256 amount
    ) internal view {
        // After buying, supply should increase by exactly the amount bought
        uint256 supplyBefore = states[0].subjectStates[subject].soulsSupply;
        uint256 supplyAfter = states[1].subjectStates[subject].soulsSupply;
        
        fl.eq(
            supplyAfter,
            supplyBefore + amount,
            "BUY_01: Supply did not increase by buy amount"
        );
    }

    function invariant_BUY_02_balanceIncreases(
        address subject,
        address buyer,
        uint256 amount
    ) internal view {
        // Buyer's balance should increase by exactly the amount bought
        uint256 balanceBefore = states[0].actorStates[buyer].soulsBalance[subject];
        uint256 balanceAfter = states[1].actorStates[buyer].soulsBalance[subject];
        
        fl.eq(
            balanceAfter,
            balanceBefore + amount,
            "BUY_02: Balance did not increase by buy amount"
        );
    }

    function invariant_BUY_03_firstSoulRule(
        address subject,
        address buyer
    ) internal view {
        // If supply was 0 before, buyer must be the subject
        uint256 supplyBefore = states[0].subjectStates[subject].soulsSupply;
        
        if (supplyBefore == 0) {
            fl.t(
                buyer == subject,
                "BUY_03: First soul can only be bought by subject"
            );
        }
    }

    // ==============================================================
    // Sell-Specific Invariants (SELL)
    // ==============================================================

    function invariant_SELL_01_supplyDecreases(
        address subject,
        uint256 amount
    ) internal view {
        // After selling, supply should decrease by exactly the amount sold
        uint256 supplyBefore = states[0].subjectStates[subject].soulsSupply;
        uint256 supplyAfter = states[1].subjectStates[subject].soulsSupply;
        
        fl.eq(
            supplyAfter,
            supplyBefore - amount,
            "SELL_01: Supply did not decrease by sell amount"
        );
    }

    function invariant_SELL_02_balanceDecreases(
        address subject,
        address seller,
        uint256 amount
    ) internal view {
        // Seller's balance should decrease by exactly the amount sold
        uint256 balanceBefore = states[0].actorStates[seller].soulsBalance[subject];
        uint256 balanceAfter = states[1].actorStates[seller].soulsBalance[subject];
        
        fl.eq(
            balanceAfter,
            balanceBefore - amount,
            "SELL_02: Balance did not decrease by sell amount"
        );
    }

    function invariant_SELL_03_cannotSellLastSoul(
        address subject
    ) internal view {
        // Supply after selling must be > 0 (cannot sell the last soul)
        uint256 supplyAfter = states[1].subjectStates[subject].soulsSupply;
        
        fl.gt(
            supplyAfter,
            0,
            "SELL_03: Supply is 0 after sell (last soul sold)"
        );
    }

    function invariant_SELL_04_sufficientBalance(
        address subject,
        address seller,
        uint256 amount
    ) internal view {
        // Seller must have had sufficient balance before selling
        uint256 balanceBefore = states[0].actorStates[seller].soulsBalance[subject];
        
        fl.gte(
            balanceBefore,
            amount,
            "SELL_04: Sold more souls than balance"
        );
    }
}
