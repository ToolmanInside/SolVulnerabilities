function Payout(uint a, uint b) internal onlyowner {
	while (a>b) {
		uint c;
		a-=1;
		if(Tx[a].txvalue < 1000000000000000000) {
			c=4;}
		else if (Tx[a].txvalue >= 1000000000000000000) {
			c=6;}
		Tx[a].txuser.send((Tx[a].txvalue/100)*c);
	}
}