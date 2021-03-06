pragma solidity 0.4.18;

//import "github.com/j4k3th3sn4ke/harambe-coin/blob/master/contracts/SafeMath.sol";

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract owned {
    address public owner;
    address public ico;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        // requires that the sender of the message must either be the coin owner or the ICO
        require(msg.sender == owner || msg.sender == ico);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }

    function transferIco(address icoAddress) onlyOwner public {
        ico = icoAddress;
    }
}

contract HarambeCoin is owned{

    // Include SafeMath solidity library
    using SafeMath for uint256;

    // Public variables of the token
    string public name;
    string public symbol;
    uint256 public decimals = 18;
    uint256 public maxSupply;
    uint256 public totalSupply;
    bool public isTradable;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed from, address indexed spender, uint256 value);

    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function HarambeCoin(
        address centralMinter
    ) public {
        maxSupply = 100000000 ether;                      // Set the total supply of coins to 100,000,000
        totalSupply = 0;                                    // Initiallizes number of minted coins to 0 
        name = "Harambe Coin";                              // Set the name for display purposes
        symbol = "HRMB";                                    // Set the symbol for display purposes
        isTradable = false;                                 // Blocks trading functions until after the ICO
        if(centralMinter != 0 ) owner = centralMinter;      // Set the owner of the contract
    }

    /**
     * Modifier used to block the transfer of HarambeCoin until after the ICO ends.
     */
    modifier tradable() {
        require(isTradable);
            _;
    }

    /**
     * Updates tradable status, for use after the ICO ends
     *
     * @param status the new bool value of tradable
     */
    function updateTradable(bool status) onlyOwner public {
        isTradable = status;
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to].add(_value) > balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from].add(balanceOf[_to]);
        // Subtract from the sender
        balanceOf[_from] = balanceOf[_from].sub(_value);
        // Add the same to the recipient
        balanceOf[_to] = balanceOf[_to].add(_value);
        Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from].add(balanceOf[_to]) == previousBalances);
    }

    /**
     * Returns total supply of the contract
     */
    function maxSuply() constant public returns (uint256 total){
        return maxSuply;
    }

    /**
     * Returns total supply of the contract
     */
    function totalSupply() constant public returns (uint256 total){
        return totalSupply;
    }

    /**
     * Returns balance of particular address of account
     */
    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balanceOf[_owner];
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public tradable returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /// @dev ERC20 transferFrom, modified such that an allowance of MAX_UINT represents an unlimited allowance.
    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint _value)
        public tradable returns (bool success)
    {
        uint allowance_amount = allowance[_from][msg.sender];
        require(balanceOf[_from] >= _value
                && allowance_amount >= _value
                && balanceOf[_to].add(_value) >= balanceOf[_to]);
        balanceOf[_to] = balanceOf[_to].add(_value);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public tradable returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Returns allowance of the owner to the pro
     */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowance[_owner][_spender];
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
    
    /**
     * Mints coins directly to wallet address
     *
     * Allows the contract owner to mint `mintedAmount` tokens to an address
     *
     * @param _to The address receiving the coins
     * @param mintedAmount The amount of coin being minted
     */
    function mintToken(address _to, uint256 mintedAmount) onlyOwner public {
        //ensures maxSupply is not gone over
        require(maxSupply >= totalSupply.add(mintedAmount));
        balanceOf[_to] = balanceOf[_to].add(mintedAmount);
        totalSupply = totalSupply.add(mintedAmount);
        Transfer(0, owner, mintedAmount);
        Transfer(owner, _to, mintedAmount);
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
