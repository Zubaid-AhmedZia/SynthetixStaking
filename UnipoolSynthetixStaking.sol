// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/450c569d78aa57e8e73547f99ec412409c73d852/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/450c569d78aa57e8e73547f99ec412409c73d852/contracts/token/ERC20/ERC20.sol";
//import "https://github.com/Creepybits/openzeppelin/blob/ecafeabad405536f647ac07567a1d74ad60eb14f/contracts/token/ERC20/ERC20Detailed.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/450c569d78aa57e8e73547f99ec412409c73d852/contracts/token/ERC20/utils/SafeERC20.sol";


contract Unipool is ERC20("Unipool", "SNX-UNP") {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 constant public REWARD_RATE = uint256(72000e18) / 7 days;
    IERC20 public snx = IERC20(0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735);
    IERC20 public uni = IERC20(0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735);

    function chechRewardRate() public pure returns(uint256){
         return uint256(72000e18) / 7 days;
    }

    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;

    event Staked(address indexed user, uint256 amount);
    event Withdrawed(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    modifier updateRewardPerToken {
        getReward();
        _;
    }

    function rewardPerToken() public view returns(uint256) {
        return rewardPerTokenStored.add(
            totalSupply() == 0 ? 0 : (block.timestamp.sub(lastUpdateTime)).mul(REWARD_RATE).mul(1e18).div(totalSupply())
        );
    }

    function earned(address account) public view returns(uint256) {
        return balanceOf(account).mul(
            rewardPerToken().sub(userRewardPerTokenPaid[account])
        ).div(1e18);
    }

    function stake(uint256 amount) public updateRewardPerToken {
        _mint(msg.sender, amount);
        uni.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public updateRewardPerToken {
        _burn(msg.sender, amount);
        uni.safeTransfer(msg.sender, amount);
        emit Withdrawed(msg.sender, amount);
    }

    function withdrawAll() public {
        withdraw(balanceOf(msg.sender));
    }

    function getReward() public {
        uint256 reward = earned(msg.sender);

        rewardPerTokenStored = rewardPerToken();
        userRewardPerTokenPaid[msg.sender] = rewardPerTokenStored;
        lastUpdateTime = block.timestamp;

        if (reward > 0) {
            snx.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }
}
 
