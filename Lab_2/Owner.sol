pragma solidity^0.5.0;

contract Fc1{
    
    address owner;           
    constructor() public{
        owner = msg.sender;                // Helps to save the address of the owner(who gives the first call)
    }
    
    modifier only_owner(){                  // So that edit access will only be with owner
        require(msg.sender == owner);
        _;
    }
    
    function receiveDeposit() payable public{
        
    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    
    
    function withdraw(uint funds) public only_owner{  // Here after public "only_owner" calls and check whether the modifier is owner or not?
        msg.sender.transfer(funds);
    }
    
    
}