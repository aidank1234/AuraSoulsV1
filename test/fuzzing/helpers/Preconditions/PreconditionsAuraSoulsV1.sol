// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PreconditionsBase.sol";
import "../FuzzStructs.sol";

contract PreconditionsAuraSoulsV1 is FuzzStructs, PreconditionsBase {
    function buySoulsPreconditions(
        uint256 subjectSeed,
        uint256 amountSeed
    ) internal returns (BuySoulsParams memory params) {
        // Select a soul subject
        params.soulsSubject = SOUL_SUBJECTS[subjectSeed % SOUL_SUBJECTS.length];
        
        // Clamp amount to reasonable range (1-100 souls)
        params.amount = fl.clamp(amountSeed, 1, 100);
        
        // Get current supply
        uint256 currentSupply = auraSoulsV1.soulsSupply(params.soulsSubject);
        
        // Calculate expected price
        params.expectedPrice = auraSoulsV1.getBuyPriceAfterFee(
            params.soulsSubject,
            params.amount
        );
        
        // Check if this should revert
        // First soul can only be bought by subject themselves
        if (currentSupply == 0 && currentActor != params.soulsSubject) {
            params.shouldRevert = true;
        } else {
            params.shouldRevert = false;
        }
    }

    function sellSoulsPreconditions(
        uint256 subjectSeed,
        uint256 amountSeed
    ) internal returns (SellSoulsParams memory params) {
        // Select a soul subject
        params.soulsSubject = SOUL_SUBJECTS[subjectSeed % SOUL_SUBJECTS.length];
        
        // Get current actor's balance for this subject
        uint256 currentBalance = auraSoulsV1.soulsBalance(
            params.soulsSubject,
            currentActor
        );
        
        // Get current supply
        uint256 currentSupply = auraSoulsV1.soulsSupply(params.soulsSubject);
        
        // Clamp amount to balance (can't sell more than owned)
        params.amount = fl.clamp(amountSeed, 1, currentBalance > 0 ? currentBalance : 1);
        
        // Calculate expected payout
        if (currentSupply > params.amount) {
            params.expectedPayout = auraSoulsV1.getSellPriceAfterFee(
                params.soulsSubject,
                params.amount
            );
        } else {
            params.expectedPayout = 0;
        }
        
        // Check if this should revert
        // Cannot sell if balance is insufficient
        if (currentBalance < params.amount) {
            params.shouldRevert = true;
        }
        // Cannot sell the last soul (supply must be > amount)
        else if (currentSupply <= params.amount) {
            params.shouldRevert = true;
        }
        else {
            params.shouldRevert = false;
        }
    }

    function setFeePercentPreconditions(
        uint256 feePercentSeed,
        uint256 feeTypeSeed
    ) internal returns (SetFeePercentParams memory params) {
        // Clamp fee percent to 0-100% (0 to 1 ether)
        params.feePercent = fl.clamp(feePercentSeed, 0, 1 ether);
        
        // Select fee type (0 = protocol, 1 = subject, 2 = lpBucket)
        params.feeType = uint8(feeTypeSeed % 3);
    }

    function randomizeSetupConfigs() internal override {
        require(!protocolSet);
        
        // Set random fee percents within valid range
        uint256 protocolFee = fl.clamp(
            generateFuzzNumber(iteration, 1),
            0,
            0.1 ether // Max 10%
        );
        uint256 subjectFee = fl.clamp(
            generateFuzzNumber(iteration, 2),
            0,
            0.1 ether // Max 10%
        );
        uint256 lpBucketFee = fl.clamp(
            generateFuzzNumber(iteration, 3),
            0,
            0.1 ether // Max 10%
        );
        
        vm.prank(owner);
        auraSoulsV1.setProtocolFeePercent(protocolFee);
        
        vm.prank(owner);
        auraSoulsV1.setSubjectFeePercent(subjectFee);
        
        vm.prank(owner);
        auraSoulsV1.setLpBucketFeePercent(lpBucketFee);
        
        protocolSet = true;
    }
}
