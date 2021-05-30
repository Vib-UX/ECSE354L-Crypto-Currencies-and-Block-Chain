pragma solidity 0.5.11; 
  

contract VotingForTopper {  
  

      address  owner; 

      string public purpose;  
       

      struct Voter{ 
          bool authorized;   
          bool voted; 
      } 
  

      uint  totalVotes; 
      uint teamA;  
      uint  teamB;  
      uint teamC; 
        
      // Creating a mapping for the total Votes 
      mapping(address=>Voter) info;  
  

      constructor( 
      string memory _name) public{  
        purpose = _name;    
        owner = msg.sender; 
      } 
     

      modifier ownerOn() { 
        require(msg.sender==owner); 
        _; 
    } 
        

      function authorize( 
      address _person) ownerOn public { 
        info[_person].authorized= true; 
          
    } 
     

      function temaAF(address _address) public {  
        require( 
        !info[_address].voted,  
        "already voted person"); 
        require( 
        info[_address].authorized,  
        "You Have No Right for Vote"); 
        info[_address].voted = true; 
        teamA++; 
        totalVotes++; 
      } 
  

      function temaBF(address _address) public { 
       require( 
       !info[_address].voted,  
       "already voted person");  
        require( 
        info[_address].authorized,  
        "You Have No Right for Vote");  
        teamB++; 
        info[_address].voted = true; 
        totalVotes++; 
      } 
  
   
      function temaCF(address _address) public returns( 
      string memory){ 
        require( 
        !info[_address].voted,  
        "already voted person");  
        require( 
        info[_address].authorized,  
        "You Have No Right for Vote");  
        info[_address].voted = true; 
        teamC++; 
        totalVotes++; 
        return("Thanks for Voting"); 
      } 
  
      function totalVotesF() public view returns(uint){ 
          return totalVotes; 
      } 
  

      function resultOfVoting() public view returns( 
      string memory){ 
          if(teamA>teamB){ 
              if(teamA>teamC){ 
                  return"A is Winning"; 
              } 
              else if(teamC>teamA){ 
                  return "C is Winning"; } } 
          else if(teamB>teamC) { 
              return "B is Winning"; 
          } 
          else if( 
          teamA==teamB && teamA==teamC || teamB==teamC ){ 
              return "No One is Winning"; 
          } 
      } 
    } 