// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const key = hre.ethers.utils.arrayify("0xdeadbeef");
const hex = hre.ethers.utils.arrayify("0x608060405234801561001057600080fd5b50610376806100206000396000f3fe608060405234801561001057600080fd5b506004361061002b5760003560e01c8063591c515f14610030575b600080fd5b61004a600480360381019061004591906100f4565b610060565b60405161005791906101ee565b60405180910390f35b606082826040516020016100759291906101ca565b604051602081830303815290604052905092915050565b600061009f61009a84610235565b610210565b9050828152602081018484840111156100b757600080fd5b6100c284828561028d565b509392505050565b600082601f8301126100db57600080fd5b81356100eb84826020860161008c565b91505092915050565b6000806040838503121561010757600080fd5b600083013567ffffffffffffffff81111561012157600080fd5b61012d858286016100ca565b925050602083013567ffffffffffffffff81111561014a57600080fd5b610156858286016100ca565b9150509250929050565b600061016b82610266565b6101758185610271565b935061018581856020860161029c565b61018e8161032f565b840191505092915050565b60006101a482610266565b6101ae8185610282565b93506101be81856020860161029c565b80840191505092915050565b60006101d68285610199565b91506101e28284610199565b91508190509392505050565b600060208201905081810360008301526102088184610160565b905092915050565b600061021a61022b565b905061022682826102cf565b919050565b6000604051905090565b600067ffffffffffffffff8211156102505761024f610300565b5b6102598261032f565b9050602081019050919050565b600081519050919050565b600082825260208201905092915050565b600081905092915050565b82818337600083830152505050565b60005b838110156102ba57808201518184015260208101905061029f565b838111156102c9576000848401525b50505050565b6102d88261032f565b810181811067ffffffffffffffff821117156102f7576102f6610300565b5b80604052505050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b6000601f19601f830116905091905056fea2646970667358221220eccb638bd672cd16d02692b3fcd1aaad54e6c50b45de0a2a0fa8b9c6632b748164736f6c63430008040033");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // const CodeCaller = await hre.ethers.getContractFactory("CodeCaller");
  // const codeCaller = await CodeCaller.deploy("Hello, Hardhat!");
  // await codeCaller.deployed();
  // console.log("CodeCaller deployed to:", codeCaller.address);

  const NFCT = await hre.ethers.getContractFactory("NFCT");
  const nfct = await NFCT.deploy();
  await nfct.deployed();
  console.log("NFCT deployed to:", nfct.address);

  let uri1 = await nfct.uri(1);
  console.log("uri1", uri1);

  const encryptedCode = await nfct.encryptDecrypt(hex, key);
  const setSubContractTx = await nfct.setEncryptedCode(1, encryptedCode);
  await setSubContractTx.wait();

  // this implicitly decrypts, deploys, and runs the encrypted code with the last two strings as args
  const runSubContractTx = await nfct.runEncryptedCode(1, "append(string,string)", key, "Hola, ", "baby!");
  await runSubContractTx.wait();

  uri1 = await nfct.uri(1);
  console.log("uri1", uri1);
  const uri2 = await nfct.uri(2);
  console.log("uri2", uri2);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
