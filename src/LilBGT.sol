// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LilBGT is ERC20, Ownable {
    address public blockRewardController;
    mapping(address => bool) public isWhitelistedSender;

    struct Validator {
        uint128 boost;
        uint224 commissionRate;
    }

    mapping(bytes => Validator) public validators;
    mapping(address => uint128) public userBoosts;
    uint128 public totalBoosts;

    uint256 private constant ONE_HUNDRED_PERCENT = 1e4;
    uint256 private constant MAX_COMMISSION_RATE = 1e3; // 10%

    constructor(address initialOwner) ERC20("Lil Bera Governance Token", "LBGT") Ownable(initialOwner) {}

    modifier onlyBlockRewardController() {
        require(msg.sender == blockRewardController, "Not block reward controller");
        _;
    }

    modifier onlyWhitelistedSender() {
        require(isWhitelistedSender[msg.sender], "Not whitelisted sender");
        _;
    }

    function setBlockRewardController(address _blockRewardController) external onlyOwner {
        blockRewardController = _blockRewardController;
    }

    function whitelistSender(address sender, bool approved) external onlyOwner {
        isWhitelistedSender[sender] = approved;
    }

    function mint(address to, uint256 amount) external onlyBlockRewardController {
        _mint(to, amount);
    }

    function transfer(address to, uint256 amount) public override onlyWhitelistedSender returns (bool) {
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override onlyWhitelistedSender returns (bool) {
        return super.transferFrom(from, to, amount);
    }

    function queueBoost(bytes calldata pubkey, uint128 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        userBoosts[msg.sender] += amount;
        validators[pubkey].boost += amount;
        totalBoosts += amount;
    }

    function cancelBoost(bytes calldata pubkey, uint128 amount) external {
        require(userBoosts[msg.sender] >= amount, "Insufficient boost");
        userBoosts[msg.sender] -= amount;
        validators[pubkey].boost -= amount;
        totalBoosts -= amount;
    }

    function setCommission(bytes calldata pubkey, uint224 rate) external {
        require(rate <= MAX_COMMISSION_RATE, "Commission too high");
        validators[pubkey].commissionRate = rate;
    }

    function boostedRewardRate(bytes calldata pubkey, uint256 rewardRate) external view returns (uint256) {
        if (totalBoosts == 0) return 0;
        return (rewardRate * validators[pubkey].boost) / totalBoosts;
    }

    function commissionRewardRate(bytes calldata pubkey, uint256 rewardRate) external view returns (uint256) {
        return (rewardRate * validators[pubkey].commissionRate) / ONE_HUNDRED_PERCENT;
    }

    function unboostedBalanceOf(address account) public view returns (uint256) {
        return balanceOf(account) - userBoosts[account];
    }
}
