// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers/FuzzStorageVariables.sol";

contract FuzzSetup is FuzzStorageVariables {
    function fuzzSetup() internal {
        deployAuraSoulsV1();
        setupSoulSubjects();
        configureAuraSoulsV1();
        labelAll();
    }

    function deployAuraSoulsV1() internal {
        auraSoulsV1 = new AuraSoulsV1(
            owner,
            PROTOCOL_FEE_DEST,
            LP_BUCKET_FEE_DEST
        );

        DONATEES.push(address(auraSoulsV1));
    }

    function setupSoulSubjects() internal {
        // Create test subjects for soul trading
        // These represent different "creators" whose souls can be traded
        SOUL_SUBJECTS.push(USER1);
        SOUL_SUBJECTS.push(USER2);
        SOUL_SUBJECTS.push(USER3);
    }

    function configureAuraSoulsV1() internal {
        // Set fee percentages
        vm.prank(owner);
        auraSoulsV1.setProtocolFeePercent(DEFAULT_PROTOCOL_FEE);
        
        vm.prank(owner);
        auraSoulsV1.setSubjectFeePercent(DEFAULT_SUBJECT_FEE);
        
        vm.prank(owner);
        auraSoulsV1.setLpBucketFeePercent(DEFAULT_LP_BUCKET_FEE);
        
        // Fund test users with ETH for buying souls
        vm.deal(USER1, 10000 ether);
        vm.deal(USER2, 10000 ether);
        vm.deal(USER3, 10000 ether);
        
        // Fund fee destinations to receive fees
        vm.deal(PROTOCOL_FEE_DEST, 1 ether);
        vm.deal(LP_BUCKET_FEE_DEST, 1 ether);
    }

    //DO LABELING
    function labelAll() internal {
        //CONTRACTS
        vm.label(address(auraSoulsV1), "AuraSoulsV1");
        vm.label(PROTOCOL_FEE_DEST, "ProtocolFeeDest");
        vm.label(LP_BUCKET_FEE_DEST, "LpBucketFeeDest");

        //USERS
        vm.label(USER1, "USER1");
        vm.label(USER2, "USER2");
        vm.label(USER3, "USER3");
        vm.label(owner, "OWNER");
    }
}
