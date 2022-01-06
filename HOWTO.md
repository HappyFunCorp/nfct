# HOWTO Construct a Non-Fungible Computing Token

This tutorial describes how to code a [Non-Fungible Computing Token](./MANIFESTO.md). It doubles as a fairly advanced Ethereum programming tutorial; if you want to catch up on the basics, first, such as what blockchain programming entails, and how to connect to a blockchain from the web, you might want to start with our [Ethereum Programming for Web Developers](https://happyfuncorp.com/whitepapers/webthereum) tutorial. If you want to know _why_ we're doing this, see our [NFCT manifesto](./MANIFESTO.md).


## 1. Credits

Like many software projects, this one is basically half boilerplate and half a Frankenstein's monster of Stack Overflow/Exchange answers. I'd like to explicitly cite and thank these ones: their actual code may or may not appear here, but they were inspirational either way.
- https://ethereum.stackexchange.com/a/69828
- https://stackoverflow.com/a/67466573
- https://ethereum.stackexchange.com/a/80016
- https://ethereum.stackexchange.com/a/11129


## 2. Setting Up An EVM Project

Once upon a time, Truffle and Ganache were the de facto rulers of EVM tooling. Today, though, there is a new hotness on the scene: Hardhat. Their [documentation](https://hardhat.org/getting-started/) is quite excellent, but, very briefly, to install Hardhat and create a sample project, you need merely

```
npm install --save-dev hardhat
npx hardhat
❯ Create a sample project
npx test
```

That sample project is a Greeter contract (full source [available](https://hardhat.org/getting-started/#compiling-your-contracts) in the Hardhat docs, again) which simply returns an (editable) greeting. When you run `npx test`, what happens behind the scenes is: that code is compiled into Ethereum bytecode; a local Ethereum network is launched; a (JavaScript) test script is run, using that network's API, to deploy that contract onto that network, and then call its method(s); finally, the results are returned to the JavaScript environment, which handles and the displays them. Even a local blockchain is extremely asynchronous, so the JavaScript code makes use of both async/await and API ".wait()" functions.


## 3. An Example Of Code Deploying New Code

Thus far we just have a boilerplate Hardhat install. Now it gets interesting. We're going to take that sample Greeter contract and turn it into _code which contains, deploys, and runs new on-chain code_, the heart of the NFCT concept. `Greeter.sol` will become `CodeCaller.sol`, and we'll "embed" new code within that contract, as an encrypted blob of data, then decrypt, deploy, and run that embedded code.

### Generating Bytecode

Storing code as data is straightforward, because all EVM contracts compile to [bytecode](https://en.wikipedia.org/wiki/Bytecode). First we generate the bytecode for the contract we're going to embed. Here it's a very basic string concatenator:

```
contract Appender {
    function append(string memory a, string memory b) public pure returns (string memory) {
        return string(abi.encodePacked(a, b));
    }
}
```

To generate its bytecode, just put it in any .sol file - e.g. paste it at the bottom of Greeter.sol - and
```
npx hardhat compile
```
Go to the `artifacts/contracts/Greeter.sol` directory, and you'll find a file "Appender.json." Open it up, and you'll find a JSON file which has a key "bytecode" with a value that's a long hex string. That hex string is, surprise surprise, the bytecode.

### Encrypting the Bytecode

NFCTs don't just store bytecode, though; they store _encrypted_ bytecode. (Otherwise, since blockchains are public, anyone would be able to see, duplicate, simulate, and run the code in question, so the NFCT wouldn't really "own" it. In some use cases that's fine, but code which is secret until run is more fun.) As such, we need to be able to encrypt this bytecode, and then, crucially, decrypt it _on-chain_.

Fortunately this is not as hard as it sounds. We'll simply use this symmetric `encryptDecrypt` method (from one of the StackExchange answers above) to use a password (aka "key") and the magic of XOR for encryption and decryption. The method in full is
```
function encryptDecrypt (bytes memory data, bytes memory key) public pure returns (bytes memory result) {
    uint256 length = data.length;

    assembly {
        result := mload (0x40)
        mstore (0x40, add (add (result, length), 32))
        mstore (result, length)
    }

    for (uint i = 0; i < length; i += 32) {
        bytes32 hash = keccak256 (abi.encodePacked (key, i));
        bytes32 chunk;
        assembly {
            chunk := mload (add (data, add (i, 32)))
        }
        chunk ^= hash;
        assembly {
            mstore (add (result, add (i, 32)), chunk)
        }
    }
}
```
Obviously other encryption implementations exist, but that should generally do for our purposes.

### Calling the Blockchain

Let's turn our attention briefly to the JavaScript which orchestrates this all -- in our case, the `test.js` contract. It will deploy the CodeCaller contract; encrypt the new embedded code; then pass that encrypted blob to the CodeCaller. To do so it uses the [ethers](https://docs.ethers.io/v5/) library that Hardhat makes available (`ethers` is to `web3` as `hardhat` is to `truffle`).

```
const { ethers } = require("hardhat");
const key = ethers.utils.arrayify("0xdeadbeef");
const hex = ethers.utils.arrayify("0xlong_bytecode_string_goes_here");
const ccFactory = await hre.ethers.getContractFactory("CodeCaller");
const codeCaller = await ccFactory.deploy("Hello, Hardhat!");
await codeCaller.deployed();
let encryptedCode = await codeCaller.encryptDecrypt(hex, key);
let setSubContractTx = await codeCaller.setEncryptedCode(encryptedCode);
await setSubContractTx.wait();
```

That blob of bytes, which is actually an encrypted Ethereum contract, is simply stored on-chain like any other EVM data;
```
bytes private _encryptedCode;
function setEncryptedCode(bytes memory code) public {
        _encryptedCode = code;
}
```

### Running the Embedded Code

OK, we've embedded the encrypted code. Now it's time to actually _run_ it. This is a four-phase process -- decrypt the code; deploy that code to the blockchain as a new contract; invoke that contract's function(s); and use any results it generates -- but for this simple example, we'll roll all those phases together into a single method: `callCode`. It's probably worth stepping through it almost line-by-line. First, though, a quick aside: let's talk about

#### Contract Creation
```
function create(bytes memory code) internal returns (address addr){
    assembly {
        addr := create(0,add(code,0x20), mload(code))
    }
}
```
This very simple function takes bytecode and uses the `create` opcode built into the EVM's [inline assembly language](https://docs.soliditylang.org/en/v0.8.10/assembly.html) Yul to deploy that bytecode to the blockchain. Remarkably simple, isn't it?

Now back to our own custom contract, and its beating heart, the `callCode` method.

##### Arguments
```
function callCode(bytes memory key, string memory abiSignature, string[] memory args) public {
```

The `key` is, of course, our encryption/decryption password. The `abiSignature` is a little more complex. Once we deploy the embedded code as a new contract, we want to call one or more of its functions. To do so, we'll need to know what that function signature is, i.e. what arguments it receives. That's its *abiSignature*, which is a string, in this case `append(string,string)`. Finally, `args` is a string array of which will be pass on to the function in question as its arguments. To see how those are handled, see below...

#### Decrypt and Deploy
```
    bytes memory subContractCode = encryptDecrypt(_encryptedCode, key); // decrypt
    _subContractAddress = create(subContractCode); // deploy
```

Fairly straightforward; we call the same `encryptDecrypt` method as before, to turn the encrypted code into unencrypted bytecode. Then we use the `create` method described above to actually deploy it to the blockchain. Note that, depending on how complex the code is, this could be quite gas-expensive.

#### Call the Code*
```
    bytes memory signature;
    if (args.length==0) {
        signature  = abi.encodeWithSignature(abiSignature);
    }
    if (args.length==1) {
        signature  = abi.encodeWithSignature(abiSignature, args[0]);
    }
    if (args.length==2) {
        signature  = abi.encodeWithSignature(abiSignature, args[0], args[1]);
    }
    if (args.length==3) {
        signature  = abi.encodeWithSignature(abiSignature, args[0], args[1], args[2]);
    }
    (bool success, bytes memory data) = _subContractAddress.call(signature);
```
This is a bit crude and hack-y but there's no easy way around it; we need to encode the function call in a way that the EVM understands, and since we don't know in advance how many arguments there are, we do so with an if tree. Needless to say you could rewrite this as a `switch`, or add an `args.length==4` if you needed that nany, etc. Honestly though three seems ample.

You may be thinking: why an array of *strings*? What if I just want to pass UINTs or bools or whatever? You're entirely right. A limitation of this kind of dynamic code is that you have to decide the argument type(s) in advance, which limits flexibility. For the purpose of this example, this is fine, but for real-world NFCTs where efficiency matters, one might want to improve on this by e.g. having one array of *strings* or *bytes* and one of *uints* -- that should cover most cases. It depends to an extent on the purpose of the NFCT in question.

#### Use the Results
```
    if (data.length == 0) {
        console.log("no data");
    } else {
        _greeting = abi.decode(data, (string));
        console.log("new greeting", _greeting);
    }
```
This is pretty straightforward (though in production you'd want to strip out Hardhat's `console.log` obviously.) This is an example of using the results of the embedded function we call; here, since CodeCaller is a descendant of the boilerplate Greeting contract, we just set a greeting.

#### The Full Source Code

The complete code (including test assertions, console.log statements, and some slight extra complexity around resetting the subContractAddress between deploying two different embedded functions) is available, of course:
- [CodeCaller.sol](./contracts/CodeCaller.sol)
- [test.js](./test/test.js)


## 4. A Complete NFCT

Let's recap what we have so far: a fully functional Ethereum contract which can dynamically accept, decrypt, deploy, and run encrypted code as a *new* Ethereum contract, and use the results of those function calls. That's pretty cool, a contract which dynamically spawns & runs new contracts on request! But it's not, you know, a *token*. Yet. So now it's time to merge the CodeCaller and existing NFT code into our long-desired NFCT.

This is much easier than you might expect, because we can simply *extend* existing NFT code and then, well, add the C. We'll write a whole new contract, `NFCT.sol`. It begins with a couple of `import` statements for ERC1155, which is the most modern standard NFT contract (it also supports fungible tokens, but never mind about that now):

```
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
```
Now import those contracts into your Hardhat project:
```
npm install @openzeppelin/contracts
```

It's probably worth looking at OpenZeppelin's ERC1155 documentation, and in particular, [Constructing an ERC1155 Token](https://docs.openzeppelin.com/contracts/3.x/erc1155#constructing_an_erc1155_token_contract). Most of the work is done for you already by the imported contract; you just need to define the NFTs you want, e.g. via

```
uint256 public constant THORS_HAMMER = 2;
constructor() public ERC1155("https://game.example/api/item/{id}.json") {
    _mint(msg.sender, THORS_HAMMER, 1, "");
}
```

That's it, that's the whole NFT contract. Our NFCT contract will of course be more complex. It will store encrypted codes, deployed contract addresses, and call results, on a per-token basis.

### NFCT.sol


```
contract NFCT is ERC1155, IERC1155NFCT {
    mapping(uint256 => bytes) private _encryptedCodes;
    mapping(uint256 => address) private _subContractAddresses;
    mapping(uint256 => bytes) private _results;

    uint256 public constant WORLDS_FIRST_NFCT = 1;
    constructor() ERC1155("https://dev.null/api/url_for_/{id}/not_yet_set.json") {
        _mint(msg.sender, 1, WORLDS_FIRST_NFCT, ""); // there's only one World's First
    }
```

Next, we basically repurpose the CodeCaller code, but for greater flexibility, divide the four phases of NFCT invocation into four separate methods. First, storing new embedded code, which only the token's owner is allowed to do:

```
    function commitEncryptedCode(uint256 tokenId, bytes memory code) external override {
        require(balanceOf(msg.sender, tokenId) > 0);
        _encryptedCodes[tokenId] = code;
    }
```

Second, decrypting and deploying that code:
```
    function decryptAndDeployCode(uint256 tokenId, bytes memory key) override public {
        require(balanceOf(msg.sender, tokenId) > 0);
        bytes memory subContractCode = encryptDecrypt(_encryptedCodes[tokenId], key);
        _subContractAddresses[tokenId] = createContract(subContractCode);
    }
```

Third, running the deployed code. Here, only the owner can call the code, but note that you could let anyone do so, or maintain a separate list of code "runners";:
```
    function runCode(uint256 tokenId, string memory abiSignature, string[] memory args) override public {
        require(balanceOf(msg.sender, tokenId) > 0); // but again note other possibilites exist...
        bytes memory signature;
        if (args.length==0) {
           signature  = abi.encodeWithSignature(abiSignature);
        }
        if (args.length==1) {
            signature  = abi.encodeWithSignature(abiSignature, args[0]);
        }
        if (args.length==2) {
            signature  = abi.encodeWithSignature(abiSignature, args[0], args[1]);
        }
        if (args.length==3) {
            signature  = abi.encodeWithSignature(abiSignature, args[0], args[1], args[2]);
        }
        (bool success, bytes memory data) = _subContractAddresses[tokenId].call(signature);
        if (success) {
            _results[tokenId] = data;
        }
    }
```

Finally, use the results. Here, for example purposes, we use the results (if any) to override the `uri` function, so the embedded code is used to change the NFT's metadata on the fly. For other potential use cases see the [MANFESTO](./MANIFESTO.md).
```
    // A very basic example of using the computed results; in this case, as this NFT's new URI.
    function uri(uint256 tokenId) public view virtual override(ERC1155, IERC1155MetadataURI) returns (string memory) {
        if (_results[tokenId].length > 0) {
            return abi.decode(_results[tokenId], (string));
        }
        return super.uri(tokenId);
    }
```

Voila! A non-fungible token contract for which each unique token includes, and can deploy/run, its own code. The full code, with some minor additional complexities such as a separate interface definition, is here: [NFCT.sol](./contracts/NFCT.sol).

## 5. Into The Real World

This works on any EVM blockchain
A note re energy use.
Install Metamask.
Select "Settings / Advanced / Show Test Network."
Select Ropsten from the list of test networks.
Drop your address into a Ropsten faucet e.g. https://faucet.ropsten.be/
Export your private key - be careful if you use, or plan to use, this account for anything else!
Update hardhat.config.js https://hardhat.org/tutorial/deploying-to-a-live-network.html#deploying-to-remote-networks
(don't push this file to a git repo with the keys still in it!)
Run deploy.js https://hardhat.org/tutorial/deploying-to-a-live-network.html
Now that the NFCT contract is deployed, run nfct.js with the generated address

## 6. Variations

Different owner/runner - "trust fall" or gaming consortia
Require previously embedded code to be run at least once before allowing new code to be committed
Unencrypted code, when you want people to know what the committed code does, e.g. "this game item X will upgrade to Y"
Different encryptDecrypt implementations
Different argument types for the embedded code
Use a minimum viable proxy to call contracts via delegatecall, so data persists across new code deployments

(replace "embedded" with "committed")