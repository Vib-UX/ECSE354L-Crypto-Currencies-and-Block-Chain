pragma solidity >=0.5.0 <0.6.0;

contract Workspace{
    
    struct Employee{
        uint emp_Id;
        string name;
        string designation;
        string department;
    }
    
    Employee [] store;
    mapping (uint => uint) emp_store;
    mapping (uint => bool) emp_chk;
    
    function addEmployee(uint empId, string memory name, string memory designation, string memory department) public{
        uint index = store.push(Employee(empId,name,designation,department))-1;
        
        emp_store[empId]=index;
        emp_chk[empId]=true;
    }
    
    function getEmployee(uint empId) public view returns(uint ID,string memory NAME, string memory DESIGNATION, string memory DEPARTMENT){
        if(emp_chk[empId]){
            return (store[emp_store[empId]].emp_Id,store[emp_store[empId]].name, store[emp_store[empId]].designation, store[emp_store[empId]].department) ;
        
        }
        return (empId," Not found","","");
    }
    
}