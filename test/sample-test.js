const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Greeter = await hre.ethers.getContractFactory("Greeter");
    const greeter = await Greeter.deploy("Hello, Hardhat!");
    await greeter.deployed();
    console.log("Greeter deployed to:", greeter.address);

    expect(await greeter.greet()).to.equal("Hello, Hardhat!");

    await greeter.createAdder("add(uint256,uint256)");
    const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await greeter.greet()).to.equal("Hola, mundo! 3");
  });
});
