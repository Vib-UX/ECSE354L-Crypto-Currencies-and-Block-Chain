pragma solidity^0.5.0;

contract FC1{
    
    address owner;           
    constructor() public{
        owner = msg.sender;               
    }
    
    function receiveDeposit() payable public{
    }
    
    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function withdraw(uint funds) public {  
        msg.sender.transfer(funds);
    }
}