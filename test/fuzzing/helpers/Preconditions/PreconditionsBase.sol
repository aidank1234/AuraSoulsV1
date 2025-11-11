// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../HelperFunctions.sol";

contract PreconditionsBase is HelperFunctions {
    event LogAddress(address actor);

    modifier setCurrentActor() {
        // First, call randomizeSetupConfigs to ensure protocol setup
        if (!protocolSet) {
            randomizeSetupConfigs();
        }
        require(protocolSet, "PreconditionsBase: Protocol not set");

        if (_setActor) {
            uint256 fuzzNumber = generateFuzzNumber(iteration, SEED);
            console.log("fuzz iteration", iteration);

            currentActor = USERS[fuzzNumber % (USERS.length)];

            iteration += 1;

            console.log("Pranking: ", toString(currentActor)); //echidna logs output
            console.log("Block timestamp: ", block.timestamp);
            //check state and revert workaround
            if (block.timestamp < lastTimestamp) {
                vm.warp(lastTimestamp);
            } else {
                lastTimestamp = block.timestamp;
            }
        }
        emit LogAddress(currentActor);
        _;
    }

    function setActor(address targetUser) internal {
        address[] memory targetArray = USERS; //use several arrays
        require(targetArray.length > 0, "Target array is empty");

        // Find target user index
        uint256 targetIndex;
        bool found = false;
        for (uint256 i = 0; i < targetArray.length; i++) {
            if (targetArray[i] == targetUser) {
                targetIndex = i;
                console.log("Setting user", targetUser);
                console.log("Index", i);

                found = true;
                break;
            }
        }

        require(found, "Target user not found in array");

        uint256 maxIterations = 100000; //  prevent infinite loops
        uint256 currentIteration = iteration;
        bool iterationFound = false;

        for (uint256 i = 0; i < maxIterations; i++) {
            uint256 hash = uint256(
                keccak256(abi.encodePacked(currentIteration * PRIME + SEED))
            );
            uint256 index = hash % targetArray.length;

            if (index == targetIndex) {
                iteration = currentIteration;
                iterationFound = true;
                break;
            }

            currentIteration++;
        }

        require(iterationFound, "User index not found by setter");
    }

    function generateSampleContractParamsBool(
        uint256 seed
    ) internal returns (bool) {
        bool param1 = seed % 2 == 0 ? true : false;
        return param1;
    }

    function generateSampleContractParamsUint256(
        uint256 seed,
        uint256 nonce
    ) internal returns (uint256) {
        bytes32 _param2 = keccak256(abi.encodePacked(seed, nonce, "param2"));
        return uint256(_param2);
    }

    function generateSampleContractParamsUint8(
        uint256 seed,
        uint256 nonce
    ) internal returns (uint8) {
        bytes32 _param3 = keccak256(abi.encodePacked(seed, nonce, "param3"));
        return uint8(uint256(_param3));
    }

    function randomizeSetupConfigs() internal virtual {
        // Override this in protocol-specific preconditions
        protocolSet = true;
    }
}
