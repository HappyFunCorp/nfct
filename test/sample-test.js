const { expect } = require("chai");
const { ethers } = require("hardhat");
const hex = ethers.utils.arrayify("0x606060405234610000575b60ad806100186000396000f30060606040526000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff168063771602f714603c575b6000565b34600057605d60048080359060200190919080359060200190919050506073565b6040518082815260200191505060405180910390f35b600081830190505b929150505600a165627a7a723058205d7bec00c6d410f7ea2a3b03112b597bb3ef544439889ecc1294a77b85eab15e0029");

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Greeter = await hre.ethers.getContractFactory("Greeter");
    const greeter = await Greeter.deploy("Hello, Hardhat!");
    await greeter.deployed();
    console.log("Greeter deployed to:", greeter.address);

    expect(await greeter.greet()).to.equal("Hello, Hardhat!");

    await greeter.createSubContract(hex, "add(uint256,uint256)");
    const setGreetingTx = await greeter.setGreeting("Hola, mundo!", 2, 3);

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await greeter.greet()).to.equal("Hola, mundo! 5");
  });
});
