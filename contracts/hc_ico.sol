pragma solidity ^0.4.16;

interface HarambeCoin {
    function mintToken(address to, uint256 value) public returns (uint256);
    function transferOwnership(address newOwner) public;
    function updateTradable(bool status) public;
}

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract ProjectHarambe is owned {
    using SafeMath for uint256;

    address private ETHWalletMultiSig;

    uint256 public totalMinted;
    uint256 public deadline;
    uint256 public etherCost;

    HarambeCoin public harambeCoin;
    mapping(address => uint256) public balanceOf;
    bool public isFunding;
    uint256 public decimals = 18;

    //event ReleaseTokens(address from, uint256 amount);
    event Contribution(address from, uint256 amount);


    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function ProjectHarambe(
        uint256 cost,
        address tokenAddress
    ) public {
        ETHWalletMultiSig = 0x0;
        if(ETHWalletMultiSig != 0 ) owner = ETHWalletMultiSig;      // Set the owner of the contract
        
        isFunding = true;
        totalMinted = 0;
        
        /* The ICO will run for 31 days (the length of January) */
        deadline = now + 744 * 60 minutes;
        
        /* Exchange rate */
        etherCost = cost * 1;

        harambeCoin = HarambeCoin(tokenAddress);
    }

    // default function
    // converts ETH to TOKEN and holds new token to be sent
    function () external payable {
        require(msg.value > 0);
        require(isFunding);
        require(now <= deadline);

        uint256 amount = msg.value.mult(etherCost);

        totalMinted =totalMinted.add(amount);

        harambeCoin.mintToken(msg.sender, amount);
        ETHWalletMultiSig.transfer(msg.value);

        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
        Contribution(msg.sender, amount);
    }

    // CONTRIBUTE FUNCTION
    // converts ETH to TOKEN and holds new token to be sent
    function contribute() external payable {
        require(msg.value > 0);
        require(isFunding);
        require(now <= deadline);

        uint256 amount = msg.value.mult(etherCost);

        totalMinted = totalMinted.add(amount);

        harambeCoin.mintToken(msg.sender, amount);
        ETHWalletMultiSig.transfer(msg.value);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
        Contribution(msg.sender, amount);
    }

    /**
     * Updates tradable status, for use after the ICO ends
     *
     * @param status the new bool value of tradable
     */
    function updateIsFunding(bool status) onlyOwner public {
        isFunding = status;
    }
    
    /**
     * Updates ether cost, for keeping price consistent
     *
     * @param uint256 cost 
     */
    function updateEtherCost(uint256 cost) onlyOwner public {
        etherCost = cost;
    }
    
    /**
     * Returns total supply of the contract
     */
    function totalMinted() constant public returns (uint256 total) {
        return totalMinted;
    }

    /**
     * Returns balance of particular address of account
     */
    function balanceOf() constant public returns (uint256 balance) {
        return balanceOf[msg.sender];
    }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
