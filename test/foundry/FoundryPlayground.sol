// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../fuzzing/Fuzz.sol";

/**
 * @title FoundryPlayground
 * @notice Reproduction tests for Echidna findings and manual testing
 * @dev Use this to reproduce specific scenarios found during fuzzing
 */
contract FoundryPlayground is Fuzz {
    /**
     * @notice Test basic buy and sell flow
     * @dev Ensures the happy path works correctly
     */
    function test_basicBuyAndSell() public {
        // Subject buys first soul
        _setActor = false;
        currentActor = USER1;
        
        fuzz_buySouls(0, 1); // Buy 1 soul
        
        // Check supply increased
        assertEq(auraSoulsV1.soulsSupply(USER1), 1, "Supply should be 1");
        assertEq(auraSoulsV1.soulsBalance(USER1, USER1), 1, "Balance should be 1");
        
        // Buy more souls
        fuzz_buySouls(0, 5); // Buy 5 more
        
        assertEq(auraSoulsV1.soulsSupply(USER1), 6, "Supply should be 6");
        assertEq(auraSoulsV1.soulsBalance(USER1, USER1), 6, "Balance should be 6");
        
        // Sell some souls (but not all)
        fuzz_sellSouls(0, 3); // Sell 3
        
        assertEq(auraSoulsV1.soulsSupply(USER1), 3, "Supply should be 3");
        assertEq(auraSoulsV1.soulsBalance(USER1, USER1), 3, "Balance should be 3");
    }
    
    /**
     * @notice Test that first soul can only be bought by subject
     * @dev This should revert when non-subject tries to buy first soul
     */
    function test_firstSoulOnlyBySubject() public {
        _setActor = false;
        currentActor = USER2;
        
        // This should fail in postconditions
        fuzz_buySouls(0, 1); // Try to buy USER1's first soul as USER2
        
        // If we get here, the fuzz handler should have caught the revert
    }
    
    /**
     * @notice Test multiple users trading same subject
     * @dev Ensures conservation of souls invariant holds
     */
    function test_multipleUsersSameSubject() public {
        _setActor = false;
        
        // USER1 (subject) buys first soul
        currentActor = USER1;
        fuzz_buySouls(0, 10);
        
        // USER2 buys some
        currentActor = USER2;
        fuzz_buySouls(0, 5);
        
        // USER3 buys some
        currentActor = USER3;
        fuzz_buySouls(0, 3);
        
        // Check conservation
        uint256 totalSupply = auraSoulsV1.soulsSupply(USER1);
        uint256 user1Balance = auraSoulsV1.soulsBalance(USER1, USER1);
        uint256 user2Balance = auraSoulsV1.soulsBalance(USER1, USER2);
        uint256 user3Balance = auraSoulsV1.soulsBalance(USER1, USER3);
        
        assertEq(
            totalSupply,
            user1Balance + user2Balance + user3Balance,
            "Conservation of souls violated"
        );
    }
    
    /**
     * @notice Test fee distribution
     * @dev Ensures fees are properly distributed to protocol, subject, and LP bucket
     */
    function test_feeDistribution() public {
        _setActor = false;
        currentActor = USER1;
        
        uint256 protocolBalBefore = PROTOCOL_FEE_DEST.balance;
        uint256 lpBucketBalBefore = LP_BUCKET_FEE_DEST.balance;
        uint256 subjectBalBefore = USER1.balance;
        
        // Buy soul (triggers fee distribution)
        fuzz_buySouls(0, 10);
        
        uint256 protocolBalAfter = PROTOCOL_FEE_DEST.balance;
        uint256 lpBucketBalAfter = LP_BUCKET_FEE_DEST.balance;
        uint256 subjectBalAfter = USER1.balance;
        
        // All fee destinations should have received fees
        assertGt(protocolBalAfter, protocolBalBefore, "Protocol fee not received");
        assertGt(lpBucketBalAfter, lpBucketBalBefore, "LP bucket fee not received");
        assertGt(subjectBalAfter, subjectBalBefore, "Subject fee not received");
    }
    
    /**
     * @notice Test price increases with supply
     * @dev Bonding curve should result in increasing prices
     */
    function test_priceIncreasesWithSupply() public {
        _setActor = false;
        currentActor = USER1;
        
        // Buy first soul
        uint256 price1 = auraSoulsV1.getBuyPriceAfterFee(USER1, 1);
        fuzz_buySouls(0, 1);
        
        // Price for next soul should be higher
        uint256 price2 = auraSoulsV1.getBuyPriceAfterFee(USER1, 1);
        assertGt(price2, price1, "Price should increase with supply");
    }
    
    /**
     * @notice Test cannot sell last soul
     * @dev Supply must always be > 0 after sell
     */
    function test_cannotSellLastSoul() public {
        _setActor = false;
        currentActor = USER1;
        
        // Buy some souls
        fuzz_buySouls(0, 5);
        
        // Try to sell all (should revert via postcondition check)
        fuzz_sellSouls(0, 5);
    }
    
    /**
     * @notice Test fee changes mid-trading
     * @dev Ensures protocol handles fee updates correctly
     */
    function test_feeChangesMidTrading() public {
        _setActor = false;
        currentActor = USER1;
        
        // Initial trade
        fuzz_buySouls(0, 5);
        
        // Change fees
        fuzz_setProtocolFeePercent(0.1 ether); // 10%
        fuzz_setSubjectFeePercent(0.1 ether); // 10%
        
        // Trade with new fees should still work
        fuzz_buySouls(0, 5);
        
        // Sell should also work
        fuzz_sellSouls(0, 3);
    }
    
    /**
     * @notice Test guided lifecycle scenario
     * @dev Uses the guided fuzzing function
     */
    function test_guidedLifecycle() public {
        fuzz_guided_buyAndSellLifecycle(0, 5, 3, 4);
    }
}
