pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
contract PharmaSol {

 	struct Vcc{
 		string mfg_name;
 		address mfg_id;
 		string current_owner;
 		address current_owner_id;
		uint  exp;
		uint  mfg;
	}

	mapping(uint => address) public vccOwner;
	mapping(address => uint) public Owner_first_id;
	mapping (address => uint) public ownerCount;
	
	Vcc[] public vaccine_store;
	
	address private mfg = 0xBb0Ad5E4AA60EE7393e7E51B5071B9b7DC5bbd44 ;
	string mfg_name;
	// uint _quantity;

	/*struct Batch_Vacc{

		uint _batch_id;
		string Name_lot;
		uint batch_quantity;
	}*/
	function add_vaccine(uint _quantity, uint _year_1, uint _year_2, string memory name) public{
			require (msg.sender == mfg);
			for(uint i=0;i<_quantity;i++){
				uint id = vaccine_store.push(Vcc(name,mfg,name,mfg,_year_1,_year_2))-1;
				vccOwner[id]=msg.sender;
				if(ownerCount[msg.sender]==0){
					Owner_first_id[msg.sender]=0;
				}
				ownerCount[msg.sender]++;
			}
	}

	function getVaccineDetails (uint id) public view returns(
		string memory MFG_NAME, 
		address MFG_ID, 
		string memory CO,
 		address CO_ID,
		uint  exp_year,
		uint mfg_year)  {


		require (id<vaccine_store.length);

		return (vaccine_store[id].mfg_name,vaccine_store[id].mfg_id,vaccine_store[id].current_owner,
			vaccine_store[id].current_owner_id,vaccine_store[id].exp,vaccine_store[id].mfg);
	}

	function transfer_Vacc(uint _quantity, address _from, address _to, string memory _name) private {
		
		ownerCount[_from]-=_quantity;
		ownerCount[_to]+=_quantity;
		
		uint temp = Owner_first_id[_from];
		for(uint i=temp;i<_quantity;i++){
			vccOwner[i]=_to;
			vaccine_store[i].current_owner=_name;
			vaccine_store[i].current_owner_id=_to;
		}
		Owner_first_id[_to]=temp;
		Owner_first_id[_from]=temp+_quantity;
	}

	function send_request_vacc(uint _quantity, address payable _from, address payable _to, string memory name) 
	public payable {
			require(msg.sender==_from && _quantity<ownerCount[_to]);
            uint256 amount = msg.value*_quantity;
			_to.transfer(amount);
			transfer_Vacc(_quantity,_to,_from,name);
	}

	function getDatabase() public view returns (Vcc[] memory){
      return vaccine_store;
    }
     function get_all_vcc_details() public view returns (string[] memory MFG_NAME, 
		address[] memory MFG_ID, 
		string[] memory CO,
 		address[] memory CO_ID,
		uint[]  memory exp_year,
		uint[] memory mfg_year){
		    
		    
      string[]    memory name_1 = new string[](vaccine_store.length);
      address[]     memory id_1 =  new address[](vaccine_store.length);
      string[]  memory name_2 = new string[](vaccine_store.length);
      address[]     memory id_2 =  new address[](vaccine_store.length);
      
      
      uint[]    memory amount_1 = new uint[](vaccine_store.length);
      uint[]    memory amount_2 = new uint[](vaccine_store.length);
      for (uint i = 0; i < vaccine_store.length; i++) {
          Vcc storage vaccine = vaccine_store[i];
          id_1[i] = vaccine.mfg_id;
          name_1[i] = vaccine.mfg_name;
          id_2[i] = vaccine.current_owner_id;
          name_2[i] = vaccine.current_owner;
          amount_1[i] = vaccine.mfg;
          amount_2[i] =vaccine.exp;
      }

      return (name_1,id_1,name_2,id_2,amount_1,amount_2);

  }
	
	
}


/*contract Manufacturer is PharmaSol{

	address private mfg = 0xBb0Ad5E4AA60EE7393e7E51B5071B9b7DC5bbd44 ;
	string mfg_name;
	// uint _quantity;

	/*struct Batch_Vacc{

		uint _batch_id;
		string Name_lot;
		uint batch_quantity;
	}
	function add_vaccine(uint _quantity, uint _year_1, uint _year_2, string calldata name) external{
			require (msg.sender == mfg);
			for(uint i=0;i<_quantity;i++){
				uint id = vaccine_store.push(Vcc(name,mfg,name,mfg,_year_1,_year_2))-1;
				vccOwner[id]=msg.sender;
				if(ownerCount[msg.sender]==0){
					Owner_first_id[msg.sender]=0;
				}
				ownerCount[msg.sender]++;
			}
	}
	

}*/
