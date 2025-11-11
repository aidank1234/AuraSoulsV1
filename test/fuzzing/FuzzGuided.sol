// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FuzzAuraSoulsV1.sol";

contract FuzzGuided is FuzzAuraSoulsV1 {
    // ==============================================================
    // GUIDED FUZZING SCENARIOS
    // ==============================================================

    /**
     * @notice Test complete lifecycle: buy first soul, buy more, then sell
     * @dev This tests the full user journey and ensures protocol handles sequential operations
     */
    function fuzz_guided_buyAndSellLifecycle(
        uint256 subjectSeed,
        uint256 buyAmount1Seed,
        uint256 buyAmount2Seed,
        uint256 sellAmountSeed
    ) public setCurrentActor {
        // Select a subject
        address subject = SOUL_SUBJECTS[subjectSeed % SOUL_SUBJECTS.length];
        
        // Ensure we're the subject (required for first soul)
        _setActor = false;
        currentActor = subject;
        
        // Step 1: Buy first soul (only subject can do this)
        uint256 buyAmount1 = fl.clamp(buyAmount1Seed, 1, 10);
        fuzz_buySouls(subjectSeed, buyAmount1);
        
        // Step 2: Buy more souls as the same user
        uint256 buyAmount2 = fl.clamp(buyAmount2Seed, 1, 10);
        fuzz_buySouls(subjectSeed, buyAmount2);
        
        // Step 3: Sell some souls
        uint256 sellAmount = fl.clamp(sellAmountSeed, 1, buyAmount1 + buyAmount2 - 1);
        fuzz_sellSouls(subjectSeed, sellAmount);
        
        // Re-enable actor randomization
        _setActor = true;
    }

    /**
     * @notice Test price consistency across buy and sell
     * @dev Ensures bonding curve pricing is symmetric
     */
    function fuzz_guided_pricingConsistency(
        uint256 subjectSeed,
        uint256 amount
    ) public setCurrentActor {
        // Setup: First user buys first soul
        address subject = SOUL_SUBJECTS[subjectSeed % SOUL_SUBJECTS.length];
        _setActor = false;
        currentActor = subject;
        
        uint256 clampedAmount = fl.clamp(amount, 1, 50);
        
        // Buy souls
        uint256 buyPrice = auraSoulsV1.getBuyPriceAfterFee(subject, clampedAmount);
        fuzz_buySouls(subjectSeed, clampedAmount);
        
        // Now check sell price at this supply
        uint256 sellPrice = auraSoulsV1.getSellPriceAfterFee(subject, clampedAmount);
        
        // Buy price should be >= sell price (due to fees)
        fl.gte(
            buyPrice,
            sellPrice,
            "Buy price should be >= sell price"
        );
        
        _setActor = true;
    }

    /**
     * @notice Test multiple users trading same subject's souls
     * @dev Ensures protocol handles concurrent trading correctly
     */
    function fuzz_guided_multipleTraders(
        uint256 subjectSeed,
        uint256 amount1,
        uint256 amount2,
        uint256 amount3
    ) public {
        address subject = SOUL_SUBJECTS[subjectSeed % SOUL_SUBJECTS.length];
        
        // Subject buys first soul
        _setActor = false;
        currentActor = subject;
        fuzz_buySouls(subjectSeed, fl.clamp(amount1, 1, 10));
        
        // USER1 buys some
        currentActor = USER1;
        fuzz_buySouls(subjectSeed, fl.clamp(amount2, 1, 10));
        
        // USER2 buys some
        currentActor = USER2;
        fuzz_buySouls(subjectSeed, fl.clamp(amount3, 1, 10));
        
        // USER1 sells some
        currentActor = USER1;
        uint256 user1Balance = auraSoulsV1.soulsBalance(subject, USER1);
        if (user1Balance > 1) {
            fuzz_sellSouls(subjectSeed, fl.clamp(amount1, 1, user1Balance - 1));
        }
        
        _setActor = true;
    }

    /**
     * @notice Test fee configuration changes mid-trading
     * @dev Ensures fee changes don't break protocol state
     */
    function fuzz_guided_feeChanges(
        uint256 subjectSeed,
        uint256 newProtocolFee,
        uint256 newSubjectFee,
        uint256 newLpBucketFee,
        uint256 amount
    ) public {
        address subject = SOUL_SUBJECTS[subjectSeed % SOUL_SUBJECTS.length];
        
        // Initial buy
        _setActor = false;
        currentActor = subject;
        fuzz_buySouls(subjectSeed, fl.clamp(amount, 1, 10));
        
        // Change fees
        fuzz_setProtocolFeePercent(newProtocolFee);
        fuzz_setSubjectFeePercent(newSubjectFee);
        fuzz_setLpBucketFeePercent(newLpBucketFee);
        
        // Buy with new fees
        currentActor = USER1;
        fuzz_buySouls(subjectSeed, fl.clamp(amount, 1, 10));
        
        _setActor = true;
    }
}
