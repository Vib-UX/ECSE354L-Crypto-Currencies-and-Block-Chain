pragma solidity^0.5.0;

contract address_save{
    
    
    address owner;
    constructor() public{
        owner = msg.sender; 	// Helps to save the address of the owner(who gives the first call)
    }
    
    function address_show() public view returns(address){
        return owner;
    }
    
    
}