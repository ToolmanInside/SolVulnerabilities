interface P3D {
	function buy(address _playerAddress) payable external returns(uint256);
}
contract Crop {
	...
	function buy(address _playerAddress) external payable onlyOwner() {
		P3D(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe).buy.value(msg.value)(_playerAddress);
	}
...}