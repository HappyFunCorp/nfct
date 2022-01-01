# Introducing the Non-Fungible Computing Token

*Introduction*

In September 2017, Dieter Shirley introduced Ethereum Improvement Proposal 721, which introduced the world to a new form of digital entity: the _non-fungible token_. After an initial, brief, CryptoKitty-fuelled excitement died down, NFTs roared back with a vengeance in 2021, a vengeance which built into a mania which became [pure full-fledged insanity](https://www.theverge.com/2021/12/30/22860010/bored-ape-yacht-club-payc-phayc-copycat-nft).

Despite this ongoing madness, we here at HappyFunCorp maintain the provocative and contrarian stance that today's NFTs are _far_ too boring. Today, we introduce an entirely new, more fun, and less boring NFT variant: the Non-Fungible Computing Token.

To be clear, we mean _technically_ boring. Today's NFTs are built on an astonishingly shaky technical edifice. An NFT merely allocates, notionally, some data - usually a URL - to a blockchain address. It's true that the ability to trigger messages from that address is guaranteed by an extraordinary technical foundation. But the link between media represented by today's NFTs is amazingly tenuous: generally, the on-chain URL points to a JSON file, hosted on some web server that may or may not respond, which in turn points to the actual image or other media, again on a server which may or may not respond, especially as time and bit rot inevitably prevail. Your NFT is not "art on the blockchain". It's (probably) not even "a link on the blockchain to art somewhere else." It's most likely "a link on the blockchain to a link somewhere else to some art somewhere even elser." (This is why NFTs are so trivially easy to duplicate.) Even if we stipulate that a marketplace for media NFTs should exist, which is arguable, does not strike HappyFunCorp's engineers as a sound technical foundation for one.

However. We are confident NFTs will eventually grow up to become more meaningful, technically sound, and energy-efficient digital goods. But even so, today's NFTs are excessively limited, because they only incorporate _data_. NFTs which include _code_, NFTs that incorporate and run their own custom software within themselves are a _far_ more fun and interesting notion than mere on-chain data, especially if that code is private / secret, despite living on a public blockchain whose every byte is accessible to all.

It may surprise you to learn that today's blockchain technologies already support such entities. Indeed, we have built them. We at HappyFunCorp hereby introduce the Non-Fungible Computing Token, or NFCT, a new kind of NFT which includes not just data but also secure, private, deployable, runnable code, viable today on all Ethereum Virtual Machine blockchains.

*How NFCTs Work*

1. Basic concept: contracts can deploy other contracts, EVM bytecode is code-as-data, deploy and call on command.
2. Security and ownership: on-chain encryption, private until run, can let ownly owner run, separate runner, anyone w password
3. Custom data: call to proxy's delegatecall lets each NFT maintain its own data structure
4. Limitations: decompilable after running, two string arguments, gas (700K to set the example, 350K to call) (although hey, maybe it's a flex)

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
