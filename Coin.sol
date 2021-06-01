pragma solidity 0.4.24;

library SafeMath {

 
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Token {
    using SafeMath for uint256;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => uint256) balances;

    uint256 totalSupply_;

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }


    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_value <= balances[msg.sender]);
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }


    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

      mapping (address => mapping (address => uint256)) internal allowed;


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(_to != address(0));

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function allowance(address _owner,address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }


    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }


    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
          allowed[msg.sender][_spender] = 0;
        } else {
          allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}

contract ICOToken is Token {
   string public name = 'ICOToken';
   string public symbol = 'ITK';
   uint256 public decimals = 18;
   address public crowdsaleAddress;
   address public owner;
   uint256 public ICOEndTime;

   modifier onlyCrowdsale {
      require(msg.sender == crowdsaleAddress);
      _;
   }

   modifier onlyOwner {
      require(msg.sender == owner);
      _;
   }

   modifier afterCrowdsale {
      require(now > ICOEndTime || msg.sender == crowdsaleAddress);
      _;
   }

   constructor (uint256 _ICOEndTime) public Token() {
      require(_ICOEndTime > 0);
           totalSupply_ = 100e24; // 100 Million
      owner = msg.sender;
      ICOEndTime = _ICOEndTime;
   }

   function setCrowdsale(address _crowdsaleAddress) public onlyOwner {
      require(_crowdsaleAddress != address(0));
      crowdsaleAddress = _crowdsaleAddress;
   }

   function buyTokens(address _receiver, uint256 _amount) public onlyCrowdsale {
      require(_receiver != address(0));
      require(_amount > 0);
      transfer(_receiver, _amount);
   }

    
    function transfer(address _to, uint256 _value) public afterCrowdsale returns(bool) {
        return super.transfer(_to, _value);
    }

    
    function transferFrom(address _from, address _to, uint256 _value) public afterCrowdsale returns(bool) {
        return super.transferFrom(_from, _to, _value);
    }

    
    function approve(address _spender, uint256 _value) public afterCrowdsale returns(bool) {
        return super.approve(_spender, _value);
    }

    
    function increaseApproval(address _spender, uint _addedValue) public afterCrowdsale returns(bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    
    function decreaseApproval(address _spender, uint _subtractedValue) public afterCrowdsale returns(bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }

    function emergencyExtract() external onlyOwner {
        owner.transfer(address(this).balance);
    }
}

contract Crowdsale {
    using SafeMath for uint256;

    bool public icoCompleted;
    uint256 public icoStartTime;
    uint256 public icoEndTime;
    uint256 public tokenRate;
    ICOToken public token;
    uint256 public fundingGoal;
    address public owner;
    uint256 public tokensRaised;
    uint256 public etherRaised;

    // To calculate Token Price: 
    // assume 1 ETH == $2500 (approx)
    // therefore, 10^18 wei = $2500 
    // therefore, 0.01 USD is 10^18 / 2500 * 100 
    // we have a decimals of 18, so we’ll use 10^18 TKNbits instead of 1 TKN
    // therefore, if the participant sends the 4 * 10^12 wei we should give them 10^18 TKNbits or 1 Token
    // therefore the rate is 4 * 10^12 wei === 10^18 TKNbits , or 1 wei = 25*10^4 TKNbits
    // therefore, our rate is 25*10^4 (Initial)     

    uint256 public rateOne = 25 * (10**(4));
    uint256 public rateTwo = 5 * (10**(5));
    uint256 public rateThree;
    
    uint256 public limitTierOne = 30e6 * (10 ** token.decimals());
    uint256 public limitTierTwo = 50e6 * (10 ** token.decimals());
    uint256 public limitTierThree = 100e6 * (10 ** token.decimals());


    modifier whenIcoCompleted {
        require(icoCompleted);
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function () public payable {
        buy();
    }

    constructor(uint256 _icoStart, uint256 _icoEnd, uint256 _tokenRate, address _tokenAddress, uint256 _fundingGoal) public {
        require(_icoStart != 0 &&
            _icoEnd != 0 &&
            _icoStart < _icoEnd &&
            _tokenRate != 0 &&
            _tokenAddress != address(0) &&
            _fundingGoal != 0);

        icoStartTime = _icoStart;
        icoEndTime = _icoEnd;
        tokenRate = _tokenRate;
        token = ICOToken(_tokenAddress);
        fundingGoal = _fundingGoal;
        owner = msg.sender;
    }

    // Rate Three Not decided yet
    function set_rate_three(uint256 new_price) onlyOwner {
        require(tokensRaised>=50e24);
        rateThree = new_price;
    }

    function calculateExcessTokens(
      uint256 amount,
      uint256 tokensThisTier,
      uint256 tierSelected,
      uint256 _rate
    ) public returns(uint256 totalTokens) {
        require(amount > 0 && tokensThisTier > 0 && _rate > 0);
        require(tierSelected >= 1 && tierSelected <= 3);

        uint weiThisTier = tokensThisTier.sub(tokensRaised).div(_rate);
        uint weiNextTier = amount.sub(weiThisTier);
        uint tokensNextTier = 0;
        bool returnTokens = false;

        // If there's excessive wei for the last tier, refund those
        if(tierSelected != 3)
            tokensNextTier = calculateTokensTier(weiNextTier, tierSelected.add(1));
        else
            returnTokens = true;

        totalTokens = tokensThisTier.sub(tokensRaised).add(tokensNextTier);

        // Do the transfer at the end
        if(returnTokens) msg.sender.transfer(weiNextTier);
   }

    function calculateTokensTier(uint256 weiPaid, uint256 tierSelected)
        internal constant returns(uint256 calculatedTokens)
    {
        require(weiPaid > 0);
        require(tierSelected >= 1 && tierSelected <= 3);

        if(tierSelected == 1)
            calculatedTokens = weiPaid.mul(rateOne);
        else if(tierSelected == 2)
            calculatedTokens = weiPaid.mul(rateTwo);
        else{
            calculatedTokens = weiPaid.mul(rateThree);
         }
   }

    function buy() public payable {
      require(tokensRaised < fundingGoal);
      require(now < icoEndTime && now > icoStartTime);

        uint256 tokensToBuy;
      uint256 etherUsed = msg.value;

      // If the tokens raised are less than 30 million with decimals, apply the first rate
      if(tokensRaised < limitTierOne) {
          // Tier 1
         tokensToBuy = etherUsed * (10 ** token.decimals()) / 1 ether * rateOne;

         // If the amount of tokens that you want to buy gets out of this tier
         if(tokensRaised + tokensToBuy > limitTierOne) {
            tokensToBuy = calculateExcessTokens(etherUsed, limitTierOne, 1, rateOne);
         }
      } else if(tokensRaised >= limitTierOne && tokensRaised < limitTierTwo) {
          // Tier 2
            tokensToBuy = etherUsed * (10 ** token.decimals()) / 1 ether * rateTwo;

            // If the amount of tokens that you want to buy gets out of this tier
            if(tokensRaised + tokensToBuy > limitTierTwo) {
            tokensToBuy = calculateExcessTokens(etherUsed, limitTierTwo, 2, rateTwo);
         }
        } else if(tokensRaised >= limitTierTwo && tokensRaised < limitTierThree) {
            // Tier 3
            tokensToBuy = etherUsed * (10 ** token.decimals()) / 1 ether * rateThree;

       }

      // Check if we have reached and exceeded the funding goal to refund the exceeding tokens and ether
      if(tokensRaised + tokensToBuy > fundingGoal) {
         uint256 exceedingTokens = tokensRaised + tokensToBuy - fundingGoal;
         uint256 exceedingEther;

         // Convert the exceedingTokens to ether and refund that ether
         exceedingEther = exceedingTokens * 1 ether / tokenRate / token.decimals();
         msg.sender.transfer(exceedingEther);

         // Change the tokens to buy to the new number
         tokensToBuy -= exceedingTokens;

         // Update the counter of ether used
         etherUsed -= exceedingEther;
      }

      // Send the tokens to the buyer
      token.buyTokens(msg.sender, tokensToBuy);

      // Increase the tokens raised and ether raised state variables
      tokensRaised += tokensToBuy;
    }

    function extractEther() public whenIcoCompleted onlyOwner {
        owner.transfer(address(this).balance);
    }
}