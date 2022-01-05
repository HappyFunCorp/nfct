# HOWTO Construct a Non-Fungible Computing Token

This tutorial describes how to code a [Non-Fungible Commputing Token](./MANIFESTO.md). It doubles as a fairly advanced Ethereum programming tutorial; if you want to catch up on the basics, first, such as what blockchain programming entails, and how to connect to a blockchain from the web, you might want to start with our [Ethereum Programming for Web Developers](https://happyfuncorp.com/whitepapers/webthereum) tutorial.

*1. Credits*

Like many software projects, this one is basically half boilerplate and half a Frankenstein's monster of Stack Overflow/Exchange answers. I'd like to explicitly cite and thank these ones: their actual code may or may not appear here, but they were inspirational either way.
- https://ethereum.stackexchange.com/a/69828
- https://stackoverflow.com/a/67466573
- https://ethereum.stackexchange.com/a/80016
- https://ethereum.stackexchange.com/a/11129


*2. Setting Up An EVM Project*

Once upon a time, Truffle and Ganache were the de facto rulers of EVM tooling. Today, though, there is a new hotness on the scene: Hardhat. Their [documentation](https://hardhat.org/getting-started/) is quite excellent, but, very briefly, to install Hardhat and create a sample project, you need merely

```
npm install --save-dev hardhat
npx hardhat
❯ Create a sample project
npx test
```

That sample project is a Greeter contract (full source [available](https://hardhat.org/getting-started/#compiling-your-contracts) in the Hardhat docs, again) which simply returns an (editable) greeting. When you run `npx test`, what happens behind the scenes is: that code is compiled into Ethereum bytecode; a local Ethereum network; a (JavaScript) test script is run, using that network's API to deploy that contract onto that network, and then call its method(s); the results of that call are returned to the JavaScript environment, which handles and the displays them. Even a local blockchain is extremely asynchronous, so the JavaScript code makes use of both async/await and API ".wait()" functions.

*3. An Example Of Code Deploying New Code*

Thus far we've just performed a boilerplate Hardhat sample project install. This is where it gets interesting. We're going to take that sample Greeter contract and turn it into _code which contains,, deploys and runs more new on-chain code_, the heart of the NFCT concept. `Greeter.sol` will become `CodeCaller.sol`, and then we're going to "embed" new code within CodeCaller as an encrypted blob of data, and then decrypt deploy, and run that embedded code.

This is relatively straightforward because all EVM contracts compile to bytecode. So, first of all, let's decide what code we're going to embed, then generate its bytecode.

- generate bytecode for the code we're going to "embed"
- encrypt/decrypt on-chain
- set encrypted code
- assembly create() method
- callCode()
- test script

*A Full NFCT Example*
- extend OpenZeppelin ERC1155
- create a basic interface
- integrate the CodeCaller code

*Variants*
- different variants, different protocols/interfaces

*Deploying and Running*
- any EVM blockchain; a note re energy use
- use HardHat to deploy NFCT contract to Rinkeby
- then to deploy and call our basic code