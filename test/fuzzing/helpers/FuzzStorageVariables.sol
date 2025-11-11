// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../../src/AuraSoulsV1.sol";
import "../utils/FuzzActors.sol";
import "../utils/FuzzConstants.sol";

contract FuzzStorageVariables is FuzzActors, FuzzConstants {
    // ==============================================================
    // FUZZING SUITE SETUP
    // ==============================================================

    address currentActor;
    bool _setActor = true;

    uint256 internal constant PRIME = 2147483647;
    uint256 internal constant SEED = 22;
    uint256 iteration = 1; // fuzzing iteration
    uint256 lastTimestamp;
    bool protocolSet;

    address[] internal TOKENS;
    address[] internal DONATEES;

    //==============================================================
    // REVERTS CONFIGURATION
    //==============================================================

    bool internal constant CATCH_REQUIRE_REVERT = true; // Set to false to ignore require()/revert()
    bool internal constant CATCH_EMPTY_REVERTS = false; // Set to true to catch empty return data

    // ==============================================================
    // LOGICAL COVERAGE CONFIGURATION
    // ==============================================================

    bool internal constant ENABLE_LOGICAL_COVERAGE = false;

    // ==============================================================
    // CONTRACTS
    // ==============================================================

    AuraSoulsV1 internal auraSoulsV1;
    
    // Test subjects for soul trading
    address[] internal SOUL_SUBJECTS;
}
