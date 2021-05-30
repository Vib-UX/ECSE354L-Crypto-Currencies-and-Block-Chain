pragma solidity^0.5.0; // solidity version
contract BC1 
{
    uint balance=1000;
    function getbalance() public view returns(uint)
    {
        return balance;
    }
    function deposit(uint newdeposit)public
    {
        balance+=newdeposit;
    }
}