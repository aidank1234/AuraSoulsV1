// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RevertHandler.sol";

abstract contract Properties_ERR is RevertHandler {
    /*
     * FUZZ NOTE: CHECK REVERTS CONFIGURATION IN FUZZ STORAGE VARIABLES
     */

    function _getAllowedPanicCodes()
        internal
        pure
        virtual
        override
        returns (uint256[] memory)
    {
        uint256[] memory panicCodes = new uint256[](2);
        
        // Allow arithmetic errors (can happen with fee calculations)
        panicCodes[0] = PANIC_ARITHMETIC;
        // Allow division by zero (edge cases in pricing)
        panicCodes[1] = PANIC_DIVISION_BY_ZERO;
        
        return panicCodes;
    }

    function _getAllowedCustomErrors()
        internal
        pure
        virtual
        override
        returns (bytes4[] memory)
    {
        // AuraSoulsV1 doesn't define custom errors, uses require/revert strings
        bytes4[] memory allowedErrors = new bytes4[](0);
        return allowedErrors;
    }

    function _isAllowedERC20Error(
        bytes memory returnData
    ) internal pure virtual override returns (bool) {
        // No ERC20 errors expected in this protocol
        return false;
    }
}
