// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBerzerkToken {
    function transferFrom(address _sender,address _recipient, uint256 amount)external returns (bool);
    function transfer(address _recipient, uint256 amount)external returns(bool);
}
contract BRKstaking{
    IBerzerkToken public brkToken;
    address public owner;

    uint256 public rewardRate = 1e18; //0.01BRK per second per token 

    mapping(address => uint256) public StakedBalance;
    mapping(address => uint256) public lastupdateTime;
    mapping(address => uint256) public rewards;

    event staked(address indexed user, uint256 amount);
    event unstaking(address indexed user,uint256 amount);
    event RewardsClaimed(address indexed user,uint256 amount);

    function earned(address account) public view returns (uint256) {
        uint256 timestaked = block.timestamp - lastupdateTime[account];
        return StakedBalance[account] * rewardRate *timestaked / 1e18;
    }

    // rest of code remains unchanged

    constructor (address _tokenAddress){
        require(_tokenAddress != address(0),"invalid token address" );
        brkToken = IBerzerkToken(_tokenAddress);
        owner = msg.sender;
    }

    modifier updateReward(address account) {
        if (account != address(0)) {
            rewards[account] += earned(account);
            lastupdateTime[account] = block.timestamp;
        }
        _;
    }
    function stake( uint256 amount )public updateReward(msg.sender) {
        require(amount > 0, "cannot stake zero tokens");
        // corrected line below to use transferFrom on brkToken contract
        require(brkToken.transferFrom(msg.sender, address(this), amount));
        StakedBalance[msg.sender] += amount;
        emit staked(msg.sender, amount);
    }
    function unstake( uint256 amount )public updateReward(msg.sender) {
        require(StakedBalance[msg.sender] >= amount, "cannot unstake more tokens than you staked");
        StakedBalance[msg.sender] -= amount;
        // corrected line below to use transferFrom on brkToken contract
        require(brkToken.transfer(msg.sender,amount));
        emit unstaking (msg.sender, amount);
    }
    function claimRewards()public updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        require (reward > 0, "no rewards to claim");
        rewards[msg.sender] = 0;
        require (brkToken.transfer(msg.sender, reward),"reward claim failed");
        emit RewardsClaimed(msg.sender, reward);
    }
    function getstakedBalances (address user) external view returns(uint256) {
        return StakedBalance[user];
    } 
 }