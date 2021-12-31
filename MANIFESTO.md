# Introducing the Non-Fungible Computing Token

*Introduction*

Today's non-fungible tokens are built on an astonishingly thin and shaky technical edifice. An NFT merely allocates, notionally, some data - usually a URL - to a blockchain address. It's true that the ability to trigger messages and control the account balances from that address is guaranteed by an extraordinary technical foundation. But the link between whatever media is represented by today's NFTs is extraordinarily tenuous: the URL points to a JSON file, hosted on some web server that may or may not respond, which in turn points to the actual image or other media, again on a server which may or may not respond as time and bit rot wear away at the world. Your NFT is not "art on the blockchain". It's (probably) not even "a link on the blockchain to art somewhere." It's most likely "a link on the blockchain to a link somewhere to some art somewhere." Speaking as an engineer, this does not strike me as an especially sound or rigorous technical foundation for a marketplace.

We are confident that, eventually, NFTs will grow up to become more technically sound (and far environmentally friendly / energy efficient!) digital goods. However, today's concept of NFTs is still excessively limiting. Even if the art _were_ on-chain, it would still only be data. An NFT which offered control not just of data but of _code_, an NFT that could include and run its own custom software - call it a Non-Fungible Computing Token - would be a far more fun & interesting notion than mere on-chain data. This would be especially true if that code were somehow private / secret, despite living on a public blockchain whose every byte is accessible to all.

You might expect the next sentence to include the word "eventually." However, there is no need to wait. We hereby introduce the Non-Fungible Computing Token, or NFCT, a new NFT variant which includes not just data but also secure, private, deployable, runnable code, available and viable _today_ on all Ethereum Virtual Machine blockchains.

*How NFCTs Work*

1. Basic concept: contracts can deploy other contracts, EVM bytecode is code-as-data, deploy and call on command.
2. Security and ownership: on-chain encryption, private until run, can let ownly owner run, separate runner, anyone w password
3. Custom data: call to proxy's delegatecall lets each NFT maintain its own data structure
4. Limitations: decompilable after running, two string arguments, gas (although hey, maybe it's a flex)

*What They're Good For*

1. IDK this was created because it was a fun notion, not because I had any actual purpose in mind
2. That said I guess I can handwave some ideas for how to use it:
3. Change the URI an NFT points to, per the code example below, challenging the very notion of "art"
4. Mystery loot for games, go on a quest for a password then run the code to find out what it is
5. Or, game item upgrades, on-chain for items transferable between games (doesn't require the code to be secret/encrypted)
6. "Trust fall NFT," one person owns it but another can deploy/run its new code
7. Multisig or script to transfer ownership, on a per-NFT level, and the script can be secret until run
8. On-chain per-NFT data via the proxy contract's delegatecall
9. Talk about gas, use energy-efficient chain for demo

*How To Make Money From NFCTs*

Believe it or not, this was done for fun, not for money. But it would be remiss not to mention that if you want to build any kind of software project - especially NFCT-related software, given that we originated the concept - you could do a lot worse than to hire us here at HappyFunCorp to do so.

*A Simple Example Of Deployable Code*

*A Full NFCT Example*
