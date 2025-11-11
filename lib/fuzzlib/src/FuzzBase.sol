// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./helpers/HelperAssert.sol";

/**
 * @title FuzzBase
 * @notice Base contract providing FuzzLib functionality via vm cheatcodes
 * @dev This is a lightweight implementation for Echidna/Foundry fuzzing
 */
contract FuzzBase is Test {
    // FuzzLib instance accessible via `fl`
    HelperAssert internal fl;

    constructor() {
        fl = new HelperAssert();
    }

    /**
     * @notice Execute a function call with proper error handling
     * @param target The contract to call
     * @param data The calldata
     * @param sender The msg.sender for the call
     * @return success Whether the call succeeded
     * @return returnData The return data or revert reason
     */
    function doFunctionCall(
        address target,
        bytes memory data,
        address sender
    ) external returns (bool success, bytes memory returnData) {
        vm.startPrank(sender);
        (success, returnData) = target.call(data);
        vm.stopPrank();
    }

    /**
     * @notice Execute a payable function call with ETH value
     * @param target The contract to call
     * @param data The calldata
     * @param sender The msg.sender for the call
     * @param value The ETH value to send
     * @return success Whether the call succeeded
     * @return returnData The return data or revert reason
     */
    function doFunctionCall(
        address target,
        bytes memory data,
        address sender,
        uint256 value
    ) external returns (bool success, bytes memory returnData) {
        vm.startPrank(sender);
        (success, returnData) = target.call{value: value}(data);
        vm.stopPrank();
    }
}
