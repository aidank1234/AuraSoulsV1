// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

/**
 * @title HelperAssert
 * @notice Helper contract providing assertion and utility functions for fuzzing
 */
contract HelperAssert is Test {
    /**
     * @notice Assert a condition is true
     * @param condition The condition to check
     * @param reason The error message if condition is false
     */
    function t(bool condition, string memory reason) external pure {
        require(condition, reason);
    }

    /**
     * @notice Assert two uint256 values are equal
     * @param a First value
     * @param b Second value
     * @param msg Error message if not equal
     */
    function eq(uint256 a, uint256 b, string memory msg) external pure {
        require(a == b, string(abi.encodePacked(msg, " (", _toString(a), " != ", _toString(b), ")")));
    }

    /**
     * @notice Assert two uint256 values are not equal
     * @param a First value
     * @param b Second value
     * @param msg Error message if equal
     */
    function neq(uint256 a, uint256 b, string memory msg) external pure {
        require(a != b, msg);
    }

    /**
     * @notice Assert first value is greater than second
     * @param a First value
     * @param b Second value
     * @param msg Error message if not greater
     */
    function gt(uint256 a, uint256 b, string memory msg) external pure {
        require(a > b, string(abi.encodePacked(msg, " (", _toString(a), " <= ", _toString(b), ")")));
    }

    /**
     * @notice Assert first value is greater than or equal to second
     * @param a First value
     * @param b Second value
     * @param msg Error message if not greater or equal
     */
    function gte(uint256 a, uint256 b, string memory msg) external pure {
        require(a >= b, string(abi.encodePacked(msg, " (", _toString(a), " < ", _toString(b), ")")));
    }

    /**
     * @notice Assert first value is less than second
     * @param a First value
     * @param b Second value
     * @param msg Error message if not less
     */
    function lt(uint256 a, uint256 b, string memory msg) external pure {
        require(a < b, string(abi.encodePacked(msg, " (", _toString(a), " >= ", _toString(b), ")")));
    }

    /**
     * @notice Assert first value is less than or equal to second
     * @param a First value
     * @param b Second value
     * @param msg Error message if not less or equal
     */
    function lte(uint256 a, uint256 b, string memory msg) external pure {
        require(a <= b, string(abi.encodePacked(msg, " (", _toString(a), " > ", _toString(b), ")")));
    }

    /**
     * @notice Clamp a value between min and max
     * @param value The value to clamp
     * @param min Minimum value
     * @param max Maximum value
     * @return The clamped value
     */
    function clamp(uint256 value, uint256 min, uint256 max) external pure returns (uint256) {
        if (value < min) return min;
        if (value > max) return max;
        return value;
    }

    /**
     * @notice Alternative name for clamp
     */
    function between(uint256 value, uint256 low, uint256 high) external pure returns (uint256) {
        if (value < low) return low;
        if (value > high) return high;
        return value;
    }

    /**
     * @notice Check if an error selector is in the allowed list
     * @param selector The error selector to check
     * @param allowed Array of allowed selectors
     * @param msg Error message if not allowed
     */
    function errAllow(bytes4 selector, bytes4[] memory allowed, string memory msg) external pure {
        for (uint256 i = 0; i < allowed.length; i++) {
            if (selector == allowed[i]) {
                return;
            }
        }
        revert(string(abi.encodePacked(msg, " (error selector not allowed)")));
    }

    /**
     * @notice Generate a random uint256
     * @param min Minimum value
     * @param max Maximum value
     * @return Random value in range
     */
    function randomUint256(uint256 min, uint256 max) external view returns (uint256) {
        uint256 range = max - min + 1;
        uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender))) % range;
        return min + rand;
    }

    /**
     * @notice Log a string message
     * @param message The message to log
     */
    function logMsg(string memory message) external view {
        console.log(message);
    }

    /**
     * @notice Log with bytes32 (as uint256 for simplicity)
     */
    function log(string memory message, bytes32 data) external view {
        console.log(message, uint256(data));
    }

    /**
     * @notice Log with string
     */
    function log(string memory message, string memory value) external view {
        console.log(message, value);
    }

    /**
     * @notice Log with uint256
     */
    function log(string memory message, uint256 value) external view {
        console.log(message, value);
    }

    /**
     * @notice Internal helper to convert uint256 to string
     */
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
