# Introducing the Non-Fungible Computing Token

## Introduction

In September 2017, Entriken, Shirley, Evans, & Sachs introduced [Ethereum Improvement Proposal 721](https://eips.ethereum.org/EIPS/eip-721), which gave the world a new form of digital entity: the _non-fungible token_, or NFT. After an initial, brief, [CryptoKitty-fuelled](https://techcrunch.com/2017/12/03/people-have-spent-over-1m-buying-virtual-cats-on-the-ethereum-blockchain/) excitement died down, NFTs roared back with a vengeance in 2021 -- a vengeance which erupted into a mania which built to [pure full-fledged insanity](https://www.theverge.com/2021/12/30/22860010/bored-ape-yacht-club-payc-phayc-copycat-nft).

Despite this ongoing madness, we at [HappyFunCorp](https://happyfuncorp.com/) maintain the provocative and contrarian stance that today's NFTs are _far_ too boring. Today we introduce an entirely new, more fun, less boring NFT variant: the Non-Fungible Computing Token.

By "boring" we mean _technically_ boring. Today's NFTs are built on an astonishingly shaky technical edifice. Such an NFT merely allocates, notionally, some data - usually a URL - to a blockchain address. It's true that the ability to trigger messages from that address is guaranteed by an extraordinary technical foundation. But the link between those addresses and the media represented by today's NFTs is amazingly tenuous: generally, the on-chain URL points to a JSON file, hosted on some off-chain web server, which in turn points to the actual image or other media, again on an external server. Today's NFTs are not "art on the blockchain". They're (probably) not even "links on the blockchain to art elsewhere." They're most likely "links on the blockchain to more links elsewhere to art even elsewherer." This is why today's NFTs are so [trivially easy](https://www.producthunt.com/posts/nft-replicas) to duplicate ... and why, as time and bit rot inevitably prevail, most will be lost like [tears in rain](https://www.youtube.com/watch?v=NoAzpa1x7jU#t=1m49s). Even if one stipulates media NFTs are good -- a thorny and nuanced dispute -- they are built on feet of technical clay.

We are confident NFTs will eventually grow up to become meaningful, technically sound, and [energy-efficient](https://blog.ethereum.org/2021/05/18/country-power-no-more/) digital goods. But even so, today's NFTs are very limited because they only incorporate _data_. NFTs which include _code_ -- NFTs that incorporate and run their own custom software within themselves, on-chain -- would be a _far_ more fun and interesting notion than mere data tokens. This is especially true if that code were somehow private / secret, despite living on a public blockchain whose every byte is accessible to all.

It may surprise you to learn that today's blockchain technologies already support such entities. We at [HappyFunCorp](https://happyfuncorp.com/) have built, and hereby introduce, the Non-Fungible Computing Token (NFCT), a new kind of NFT which includes not just data but also secure, private, runnable code, viable today on all Ethereum Virtual Machine blockchains.

## How NFCTs Work

Ethereum Virtual Machine (EVM) programs are compiled to "bytecode," long strings of binary data. A fundamental aspect of Ethereum smart contracts is that they can call _and deploy_ other smart contracts. This means one can store the bytecode of an EVM contract as data within one contract, and then, subsequently, deploy and run that code as another contract. This concept is the heart of the Non-Fungible Computing Token.

NFCTs do _not_ deploy/run their code immediately upon receipt. Instead, they first store their code on-chain, and then, later, in a separate transaction, deploy and run it. This distinction is subtle, but extremely important; it's the difference between [_committing_](https://cdixon.org/2020/01/26/computers-that-can-make-commitments) code, vs. not. The gap between "I totally could deploy Code X to this NFCT, someday, if I ever feel like it" and "Code X has _already been committed_, and is there on the blockchain waiting to be triggered" is huge. (To strengthen that commitment, one could easily construct NFCTs which  reject any new code until their existing code has been deployed and run.)

All data on Ethereum blockchains is public. To ensure an NFCT's code is secret until deployed, this reference implementation receives _encrypted_ code, and requires a decryption password to deploy it. A beneficial effect is that NFCTs can be structured such that anyone with the password, not just the owner, can trigger deployment. It would also be easy to construct NFCTs which have one _owner_ and another, entirely separate _runner_, i.e. the entity allowed to run its code. (A friend refers to this notion as the "trust fall" version.)

Like all software, NFCTs come with compromises and limitations. They are complex contracts, so the gas costs to deploy and run code will be quite high; even with our simple [reference example](./HOWTO.md), it would as of this writing cost hundreds of dollars to deploy and then run its own code on the Ethereum blockchain. Furthermore, there is no way to maintain code secrecy after the code has been deployed; granted, decompilation and/or simulation won't be _easy_, but one certainly shouldn't consider deployed code secure.

A theoretical concept worth noting is that it should be possible for each NFCT to maintain its own data -- which can be edited by its deployed code, _across different code deployments and invocations_ -- by maintaining a per-token [Minimal Proxy Contract](https://eips.ethereum.org/EIPS/eip-1167) which makes use of the magic of [delegatecall](https://docs.soliditylang.org/en/v0.8.10/introduction-to-smart-contracts.html#delegatecall-callcode-and-libraries). This would be tricky, but should be doable, and opens up a panoply of potentially interesting possibilities.

## What They're Good For

To be clear, NFCTs were created because the concept was fun and technically interesting, not as a solution to any particular problem. Furthermore, we view them more as a new kind of Lego block than a completed edifice. That said, we can handwave some ideas of how they might be used:

1. "Mystery loot" NFTs, whose contents have been committed to the chain in the form of code, but aren't revealed until the password is distributed, the code is run, and the data it generates is written. This data could even be dynamic based on runtime oracle values, block number, etc.
2. In general, game and especially _cross-game_ NFTs are the most obvious use case. NFCTs could be in-game items with committed "ugrade paths," wherein if you find the password in the game, you can then activate the upgrade code. This could even be done _cross-game_, wherein a consortium of games would follow an understood data protocol such that an upgrade in Game A would also be reflected in Game B. In such a case, the player would _own_ the NFT, but only consortium members could deploy new "item upgrades." (Here, encryption might not be necessary, and the commitment step could be used to ensure consortium approval.)
3. You'd want to be careful with this, but you could probably override ERC721 or ERC1155 methods to implement some kind of per-token multisig or other script-based code to transfer token ownership -- code which is secret until actually deployed/run.
4. Completely on-chain custom per-NFT data, as per the last paragraph of the previous section.
5. "Trust fall" NFTs in which one address is the "owner," another is the "runner" who can set, deploy, and run its code, and both ownership and runnership can be transferred / resold independently.
6. As per our [reference example](./HOWTO.md), use deployed code to dynamically change the URI that a media NFT points to, thereby challenging the very concept of "art" (and "token") in an appropriately avant-garde Situationist kind of way.
7. ...again, though, this is really a new kind of Lego block; we expect it to fit into a whole cornucopia of projects in a wide variety of ways.

## How To Make Money From NFCTs

Sigh. Again, this was done for fun not money, and as is probably clear from the above, we think the NFT frenzy ongoing as of this writing is irrational and in many ways destructive. We're glad artists are getting paid, especially outsider artists, and we do think that _eventually_ ownership of digital goods via NFTs will make a lot of sense ... but at the same time, the scams, hucksterism, wash trading, ephemerality, and sizable environmental costs of today's NFTs combine to make us us roll our eyes profoundly at this subject. Right now, NFCTs make exactly as much inherent financial sense as other NFTs, which is to say, essentially none.

That said: we do believe there are babies in with this bathwater, and that, _in time_, in the context of environments / systems / frameworks / marketplaces / games which add real value, NFCTs will be a crucial building block for digital goods. So it would be remiss not to mention that if you are building such a system, you could do a lot worse than to give us here at [HappyFunCorp](https://happyfuncorp.com/) a call.

## A Technical Tutorial

If you're an interested software developer, for a description of NFCTs in much greater technical depth, head on over to the [HOWTO](./HOWTO.md).

-- [HappyFunCorp](https://happyfuncorp.com/), January 2022
