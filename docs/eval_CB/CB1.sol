CB1
###

interface P3DTakeout {
	function buyTokens() external payable;
}
contract Betting{
	...
	uint public winnerPoolTotal;
	P3DTakeout P3DContract_;
	uint public total_reward; // reward to be awarded
	constructor() public payable {
		owner = msg.sender;
		horses.BTC = bytes32("BTC");
		P3DContract_ = P3DTakeout(0x72b2670e55139934D6445348DC6EaB4089B12576);
	...}
	function reward() internal {
		total_reward = coinIndex[horses.BTC].total + ... ;
		P3DContract_.buyTokens.value(p3d_fee)();
		...
		winnerPoolTotal = coinIndex[horses.BTC].total;
	...}
}