const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const GreeterDelegate = await hre.ethers.getContractFactory("GreeterDelegate");
    const greeterDelegate = await await GreeterDelegate.deploy("Hello, Hardhat Delegate!");
    await greeterDelegate.deployed();
    console.log("Greeter delegate deployed to:", greeterDelegate.address);
  
    const Greeter = await hre.ethers.getContractFactory("Greeter");
    const greeter = await Greeter.deploy("Hello, Hardhat!", greeterDelegate.address);
    await greeter.deployed();
    console.log("Greeter deployed to:", greeter.address);

    expect(await greeter.greet()).to.equal("Hello, Hardhat!");

    const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await greeter.greet()).to.equal("Hola, mundo! 3");
  });
});
