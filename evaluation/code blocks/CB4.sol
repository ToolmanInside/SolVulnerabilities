contract ZethrBankroll is ERC223Receiving {
  ZTHInterface public ZTHTKN;
  bool internal reEntered;
  function receiveDividends() public payable {
    if (!reEntered) {
      ...
      if (ActualBalance > 0.01 ether) {
        reEntered = true;
        ZTHTKN.buyAndSetDivPercentage.value(ActualBalance)(address(0x0), 33, "");
        reEntered = false;	}
    }
  }
}
contract ZTHInterface {
	function buyAndSetDivPercentage(address _referredBy, uint8 _divChoice, string providedUnhashedPass) public payable returns (uint);
}