// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers/Preconditions/PreconditionsAuraSoulsV1.sol";
import "./helpers/Postconditions/PostconditionsAuraSoulsV1.sol";

contract FuzzAuraSoulsV1 is
    PreconditionsAuraSoulsV1,
    PostconditionsAuraSoulsV1
{
    // ==============================================================
    // CORE PROTOCOL HANDLERS
    // ==============================================================

    function fuzz_buySouls(
        uint256 subjectSeed,
        uint256 amountSeed
    ) public setCurrentActor {
        // 1. PRECONDITIONS - Validate, bound, and prepare ALL inputs
        BuySoulsParams memory params = buySoulsPreconditions(subjectSeed, amountSeed);

        // 2. BEFORE - Capture state snapshot
        _before();

        // 3. EXECUTE - Call via FuzzLib proxy
        (bool success, bytes memory returnData) = fl.doFunctionCall(
            address(auraSoulsV1),
            abi.encodeWithSelector(
                AuraSoulsV1.buySouls.selector,
                params.soulsSubject,
                params.amount
            ),
            currentActor,
            params.expectedPrice // Send the required ETH
        );

        // 4. POSTCONDITIONS - Validate state changes
        buySoulsPostconditions(success, returnData, params);
    }

    function fuzz_sellSouls(
        uint256 subjectSeed,
        uint256 amountSeed
    ) public setCurrentActor {
        // 1. PRECONDITIONS
        SellSoulsParams memory params = sellSoulsPreconditions(subjectSeed, amountSeed);

        // 2. BEFORE
        _before();

        // 3. EXECUTE
        (bool success, bytes memory returnData) = fl.doFunctionCall(
            address(auraSoulsV1),
            abi.encodeWithSelector(
                AuraSoulsV1.sellSouls.selector,
                params.soulsSubject,
                params.amount
            ),
            currentActor
        );

        // 4. POSTCONDITIONS
        sellSoulsPostconditions(success, returnData, params);
    }

    // ==============================================================
    // OWNER-ONLY HANDLERS
    // ==============================================================

    function fuzz_setProtocolFeePercent(uint256 feePercentSeed) public {
        // Only owner can call
        SetFeePercentParams memory params;
        params.feePercent = fl.clamp(feePercentSeed, 0, 1 ether);
        params.feeType = 0;

        _before();

        vm.prank(owner);
        (bool success, bytes memory returnData) = fl.doFunctionCall(
            address(auraSoulsV1),
            abi.encodeWithSelector(
                AuraSoulsV1.setProtocolFeePercent.selector,
                params.feePercent
            ),
            owner
        );

        setFeePercentPostconditions(success, returnData);
    }

    function fuzz_setSubjectFeePercent(uint256 feePercentSeed) public {
        // Only owner can call
        SetFeePercentParams memory params;
        params.feePercent = fl.clamp(feePercentSeed, 0, 1 ether);
        params.feeType = 1;

        _before();

        vm.prank(owner);
        (bool success, bytes memory returnData) = fl.doFunctionCall(
            address(auraSoulsV1),
            abi.encodeWithSelector(
                AuraSoulsV1.setSubjectFeePercent.selector,
                params.feePercent
            ),
            owner
        );

        setFeePercentPostconditions(success, returnData);
    }

    function fuzz_setLpBucketFeePercent(uint256 feePercentSeed) public {
        // Only owner can call
        SetFeePercentParams memory params;
        params.feePercent = fl.clamp(feePercentSeed, 0, 1 ether);
        params.feeType = 2;

        _before();

        vm.prank(owner);
        (bool success, bytes memory returnData) = fl.doFunctionCall(
            address(auraSoulsV1),
            abi.encodeWithSelector(
                AuraSoulsV1.setLpBucketFeePercent.selector,
                params.feePercent
            ),
            owner
        );

        setFeePercentPostconditions(success, returnData);
    }
}
