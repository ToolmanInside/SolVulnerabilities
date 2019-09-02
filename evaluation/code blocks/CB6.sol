function withdraw() private {
	for(uint i = 0; i < player_[uid].planCount; i++) {
		if (player_[uid].plans[i].isClose) { continue;  }
		// amount calculation
		...
		// send the calculated amount directly to sender
		address sender = msg.sender;
		sender.transfer(amount);
		// record block number and the amount of this trans.
		player_[uid].plans[i].atBlock = block.number;
		player_[uid].plans[i].isClose = bClose;
		player_[uid].plans[i].payEth += amount;
	}
}