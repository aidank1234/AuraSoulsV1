// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AuraSoulsV1 is ReentrancyGuard, Ownable {
    address public protocolFeeDestination;
    address public lpBucketFeeDestination;
    uint256 public protocolFeePercent;
    uint256 public subjectFeePercent;
    uint256 public lpBucketFeePercent;

    event Trade(
        address trader,
        address subject,
        bool isBuy,
        uint256 soulAmount,
        uint256 ethAmount,
        uint256 protocolEthAmount,
        uint256 subjectEthAmount,
        uint256 lpBucketEthAmount,
        uint256 supply
    );

    // SoulsSubject => (Holder => Balance)
    mapping(address => mapping(address => uint256)) public soulsBalance;

    // SoulsSubject => Supply
    mapping(address => uint256) public soulsSupply;

    // Track total creator earnings
    mapping(address => uint256) public creatorEarnings;

    // Constructor
    constructor(
        address _owner,
        address _protocolFeeDestination,
        address _lpBucketFeeDestination
    ) Ownable(_owner) ReentrancyGuard() {
        protocolFeeDestination = _protocolFeeDestination;
        lpBucketFeeDestination = _lpBucketFeeDestination;
    }

    // Setters for fee and destinations
    function setProtocolFeePercent(uint256 _feePercent) public onlyOwner {
        require(_feePercent <= 1 ether, "Fee percent must be <= 100%");
        protocolFeePercent = _feePercent;
    }

    function setSubjectFeePercent(uint256 _feePercent) public onlyOwner {
        require(_feePercent <= 1 ether, "Fee percent must be <= 100%");
        subjectFeePercent = _feePercent;
    }

    function setLpBucketFeePercent(uint256 _feePercent) public onlyOwner {
        require(_feePercent <= 1 ether, "Fee percent must be <= 100%");
        lpBucketFeePercent = _feePercent;
    }

    function cumulativeSum(uint256 n) internal pure returns (uint256) {
        return (n * (n + 1) * (2 * n + 1)) / 6;
    }

    function getPrice(uint256 supply, uint256 amount)
        public
        pure
        returns (uint256)
    {
        uint256 start = supply == 0 ? 0 : supply - 1;
        uint256 end = supply + amount - 1;
        uint256 sum1 = cumulativeSum(start);
        uint256 sum2 = cumulativeSum(end);
        uint256 summation = sum2 - sum1;
        return (summation * 1 ether) / 16000;
    }

    function getBuyPriceAfterFee(address soulsSubject, uint256 amount)
        public
        view
        returns (uint256)
    {
        uint256 price = getPrice(soulsSupply[soulsSubject], amount);
        return applyFees(price, true);
    }

    function getSellPriceAfterFee(address soulsSubject, uint256 amount)
        public
        view
        returns (uint256)
    {
        uint256 price = getPrice(soulsSupply[soulsSubject] - amount, amount);
        return applyFees(price, false);
    }

    function applyFees(uint256 price, bool isBuy)
        internal
        view
        returns (uint256 finalPrice)
    {
        uint256 protocolFee = (price * protocolFeePercent) / 1 ether;
        uint256 subjectFee = (price * subjectFeePercent) / 1 ether;
        uint256 lpBucketFee = (price * lpBucketFeePercent) / 1 ether;

        if (isBuy) {
            finalPrice = price + protocolFee + subjectFee + lpBucketFee;
        } else {
            finalPrice = price - protocolFee - subjectFee - lpBucketFee;
        }
    }

    function buySouls(address soulsSubject, uint256 amount)
        public
        payable
        nonReentrant
    {
        uint256 price = getPrice(soulsSupply[soulsSubject], amount);
        uint256 totalPrice = applyFees(price, true);
        require(msg.value == totalPrice, "Incorrect payment amount");

        // Update state
        soulsBalance[soulsSubject][msg.sender] += amount;
        soulsSupply[soulsSubject] += amount;
        creatorEarnings[soulsSubject] += (price * subjectFeePercent) / 1 ether;

        emit Trade(
            msg.sender,
            soulsSubject,
            true,
            amount,
            price,
            (price * protocolFeePercent) / 1 ether,
            (price * subjectFeePercent) / 1 ether,
            (price * lpBucketFeePercent) / 1 ether,
            soulsSupply[soulsSubject]
        );

        // Transfer fees
        distributeFees(
            (price * protocolFeePercent) / 1 ether,
            (price * subjectFeePercent) / 1 ether,
            (price * lpBucketFeePercent) / 1 ether,
            soulsSubject
        );
    }

    function sellSouls(address soulsSubject, uint256 amount)
        public
        nonReentrant
    {
        uint256 price = getPrice(soulsSupply[soulsSubject] - amount, amount);
        uint256 totalPayout = applyFees(price, false);

        require(
            soulsBalance[soulsSubject][msg.sender] >= amount,
            "Insufficient souls"
        );

        // Update state
        soulsBalance[soulsSubject][msg.sender] -= amount;
        soulsSupply[soulsSubject] -= amount;
        creatorEarnings[soulsSubject] += (price * subjectFeePercent) / 1 ether;

        emit Trade(
            msg.sender,
            soulsSubject,
            false,
            amount,
            price,
            (price * protocolFeePercent) / 1 ether,
            (price * subjectFeePercent) / 1 ether,
            (price * lpBucketFeePercent) / 1 ether,
            soulsSupply[soulsSubject]
        );

        // Transfer funds
        distributeFees(
            (price * protocolFeePercent) / 1 ether,
            (price * subjectFeePercent) / 1 ether,
            (price * lpBucketFeePercent) / 1 ether,
            soulsSubject
        );

        (bool success, ) = msg.sender.call{value: totalPayout}("");
        require(success, "Unable to send payout");
    }

    function distributeFees(
        uint256 protocolFee,
        uint256 subjectFee,
        uint256 lpBucketFee,
        address soulsSubject
    ) internal {
        (bool success1, ) = protocolFeeDestination.call{value: protocolFee}("");
        (bool success2, ) = soulsSubject.call{value: subjectFee}("");
        (bool success3, ) = lpBucketFeeDestination.call{value: lpBucketFee}("");
        require(success1 && success2 && success3, "Fee transfer failed");
    }
}
