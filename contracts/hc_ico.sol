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
    address private ETHWalletMultiSig;

    uint public totalMinted;
    //uint public etherRaised;
    uint public deadline;
    uint public etherCost;
    //uint256 public exchangeRate;

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
        uint cost,
        address tokenAddress
    ) public {
        ETHWalletMultiSig = 0x0;
        if(centralMinter != 0 ) owner = ETHWalletMultiSig;      // Set the owner of the contract

        isFunding = true;
        totalMinted = 0;
        //etherRaised = 0;

        /* The ICO will run for 31 days (the length of January) */
        deadline = now + 744 * 60 minutes;

        /* Exchange rate */
        etherCost = cost * 1;
        //etherCost = etherCost / (10 ** decimals);
        //exchangeRate = etherCost / 1 ether;
        harambeCoin = HarambeCoin(tokenAddress);
    }

    // default function
    // converts ETH to TOKEN and holds new token to be sent
    function () external payable projectActive {
        require(msg.value > 0);
        require(isFunding);
        require(now <= deadline);

        uint256 amount = msg.value * etherCost;

        totalMinted += amount;

        //ETHWalletHarambe.transfer(msg.value);
        harambeCoin.mintToken(msg.sender, amount);
        balanceOf[msg.sender] += amount;
        Contribution(msg.sender, amount);
    }

    // CONTRIBUTE FUNCTION
    // converts ETH to TOKEN and holds new token to be sent
    function contribute() external payable {
        require(msg.value > 0);
        require(isFunding);
        require(now <= deadline);

        uint256 amount = msg.value * etherCost;

        totalMinted += amount;

        //ETHWalletHarambe.transfer(msg.value);
        harambeCoin.mintToken(msg.sender, amount);
        balanceOf[msg.sender] += amount;
        Contribution(msg.sender, amount);
    }

    function endProject() onlyOwner public {
        isFunding = false;
        harambeCoin.transferOwnership(ETHWalletMultiSig);
        harambeCoin.updateTradable(true);
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
