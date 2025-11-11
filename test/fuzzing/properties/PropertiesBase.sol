// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../helpers/BeforeAfter.sol";

abstract contract PropertiesBase is BeforeAfter {
    // ==============================================================
    // ERROR MESSAGES
    // ==============================================================

    string internal constant ERR_01 = "Disallowed error encountered";
    string internal constant ERR_02 = "Unexpected state change";
    string internal constant ERR_03 = "Invariant violation";

    // ==============================================================
    // PANIC CODE CONSTANTS
    // ==============================================================

    uint256 internal constant PANIC_ASSERT = 0x01;
    uint256 internal constant PANIC_ARITHMETIC = 0x11;
    uint256 internal constant PANIC_DIVISION_BY_ZERO = 0x12;
    uint256 internal constant PANIC_ENUM_OUT_OF_BOUNDS = 0x21;
    uint256 internal constant PANIC_ARRAY_OUT_OF_BOUNDS = 0x32;
    uint256 internal constant PANIC_MEMORY_OVERFLOW = 0x41;
    uint256 internal constant PANIC_UNINITIALIZED_FUNCTION = 0x51;
    uint256 internal constant PANIC_POP_EMPTY_ARRAY = 0x31;

    // ==============================================================
    // SOLADY ERC20 ERROR CONSTANTS
    // ==============================================================

    bytes internal constant INSUFFICIENT_ALLOWANCE =
        abi.encodeWithSignature("InsufficientAllowance()");
    bytes internal constant TRANSFER_FROM_ZERO =
        abi.encodeWithSignature("TransferFromZeroAddress()");
    bytes internal constant TRANSFER_TO_ZERO =
        abi.encodeWithSignature("TransferToZeroAddress()");
    bytes internal constant APPROVE_TO_ZERO =
        abi.encodeWithSignature("ApproveToZeroAddress()");
    bytes internal constant MINT_TO_ZERO =
        abi.encodeWithSignature("MintToZeroAddress()");
    bytes internal constant BURN_FROM_ZERO =
        abi.encodeWithSignature("BurnFromZeroAddress()");
    bytes internal constant DECREASED_ALLOWANCE =
        abi.encodeWithSignature("AllowanceBelowZero()");
    bytes internal constant BURN_EXCEEDS_BALANCE =
        abi.encodeWithSignature("BurnExceedsBalance()");
    bytes internal constant EXCEEDS_BALANCE_ERROR =
        abi.encodeWithSignature("InsufficientBalance()");
}
