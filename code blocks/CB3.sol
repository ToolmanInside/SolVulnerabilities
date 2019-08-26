contract RegDocuments {
 modifier onlyAdmin() {
  if (msg.sender!= admin && msg.sender!=owner) revert();
  ...;
 }
 constructor() {
  admin = msg.sender;
  owner = 0xc238ff50c09787e7b920f711850dd945a40d3232;
 }
 function regstDocs(bytes32 _storKey) onlyAdmin payable{
  uint _value = Storage.regPrice();
  Storage.regstUser.value(_value)(_storKey);
 }		
}
contract GlobalStorageMultiId { // Interface for Storage
 uint256 public regPrice;
 function regstUser(bytes32 _id) payable returns(bool);
}