pragma solidity^0.5.0; // Solidity version

contract smart{
    
    function receiveDeposit() payable public{
        
    }
    
    function getbalance() public view returns(uint){
        return address(this).balance;
    }
    
    
    
}