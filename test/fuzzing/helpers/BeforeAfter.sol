// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./HelperFunctions.sol";

contract BeforeAfter is HelperFunctions {
    mapping(uint8 => State) states;

    struct State {
        mapping(address => ActorStates) actorStates;
        mapping(address => SubjectStates) subjectStates;
        uint256 protocolFeeDestBalance;
        uint256 lpBucketFeeDestBalance;
        uint256 contractEthBalance;
    }

    struct ActorStates {
        uint256 userEthBalance;
        mapping(address => uint256) soulsBalance; // soulsBalance[subject]
    }

    struct SubjectStates {
        uint256 soulsSupply;
        uint256 creatorEarnings;
        uint256 totalBalances; // Sum of all holder balances
    }

    function _before() internal {
        _before(USERS);
    }

    function _after() internal {
        _after(USERS);
    }

    // SUPER IMPORTANT:
    // All donation receivers should be processed in BeforeAfter
    // Including protocol actors
    function _before(address[] memory actors) internal {
        _setStates(0, actors);
    }

    // SUPER IMPORTANT:
    // All donation receivers should be processed in BeforeAfter
    // Including protocol actors
    function _after(address[] memory actors) internal {
        _setStates(1, actors);
    }

    function _setStates(uint8 callNum, address[] memory actors) internal {
        _processActors(callNum, actors);
        _updateCommonState(callNum);
    }

    function _processActors(uint8 callNum, address[] memory actors) private {
        for (uint256 i = 0; i < actors.length; i++) {
            _setActorState(callNum, actors[i]);
        }
        
        // Also process soul subjects
        for (uint256 i = 0; i < SOUL_SUBJECTS.length; i++) {
            _setSubjectState(callNum, SOUL_SUBJECTS[i]);
        }
    }

    function _updateCommonState(uint8 callNum) private {
        checkContractEthBalance(callNum);
        checkFeeDestinationBalances(callNum);
    }

    function _setActorState(uint8 callNum, address actor) internal virtual {
        checkUserEthBalance(callNum, actor);
        checkUserSoulsBalances(callNum, actor);
    }
    
    function _setSubjectState(uint8 callNum, address subject) internal virtual {
        checkSubjectSoulsSupply(callNum, subject);
        checkSubjectCreatorEarnings(callNum, subject);
        checkSubjectTotalBalances(callNum, subject);
    }

    function checkUserEthBalance(uint8 callNum, address user) internal {
        states[callNum].actorStates[user].userEthBalance = user.balance;
    }

    function checkUserSoulsBalances(uint8 callNum, address user) internal {
        for (uint256 i = 0; i < SOUL_SUBJECTS.length; i++) {
            address subject = SOUL_SUBJECTS[i];
            states[callNum].actorStates[user].soulsBalance[subject] = 
                auraSoulsV1.soulsBalance(subject, user);
        }
    }
    
    function checkSubjectSoulsSupply(uint8 callNum, address subject) internal {
        states[callNum].subjectStates[subject].soulsSupply = 
            auraSoulsV1.soulsSupply(subject);
    }
    
    function checkSubjectCreatorEarnings(uint8 callNum, address subject) internal {
        states[callNum].subjectStates[subject].creatorEarnings = 
            auraSoulsV1.creatorEarnings(subject);
    }
    
    function checkSubjectTotalBalances(uint8 callNum, address subject) internal {
        states[callNum].subjectStates[subject].totalBalances = getSumOfBalances(subject);
    }

    function checkContractEthBalance(uint8 callNum) internal {
        states[callNum].contractEthBalance = address(auraSoulsV1).balance;
    }
    
    function checkFeeDestinationBalances(uint8 callNum) internal {
        states[callNum].protocolFeeDestBalance = PROTOCOL_FEE_DEST.balance;
        states[callNum].lpBucketFeeDestBalance = LP_BUCKET_FEE_DEST.balance;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}
