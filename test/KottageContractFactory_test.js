const { expect } = require("chai");

function printEvent(log)
{
  if (log.eventName === "KottageContractCreated") {
    // Process the log
    console.log(`KottageContractCreated event: address: ${log.args[0]}, owner: ${log.args[1]}, name: ${log.args[2]}, symbol: ${log.args[3]}`);
  }
}      

describe("KottageContractFactory", function () {
  it("Deployment should create a contract owned by deployer", async function () {
    const [owner] = await ethers.getSigners();

    const hardhatContractFactory = await ethers.getContractFactory("KottageContractFactory");
    const hardhatContract = await hardhatContractFactory.deploy();
    const _owner = await hardhatContract.owner();

    expect(_owner).to.equal(owner.address);
  }),
  it("Should properly deploy a KottageToken contract with the name and symbol", async function() {
    const [owner] = await ethers.getSigners();

    const hardhatContractFactory = await ethers.getContractFactory("KottageContractFactory");
    const hardhatContract = await hardhatContractFactory.deploy();

    const symbol = "TST";
    const name = "TestToken";
    const uri = "https://example.com/test.json";

    const tx = await hardhatContract.createKottageContract(name, symbol, uri);
    const receipt = await tx.wait();

    for (let log of receipt.logs) {
      printEvent(log);
    }

    const mintEvent = receipt.logs?.filter((x) => { return x.eventName == "KottageContractCreated" });
    const tokenAddress = mintEvent[0].args[0];

    expect(await hardhatContract.addr2ContractsLength(owner.address)).to.equal(1);
    expect(await hardhatContract.getContractByAddrIndex(owner.address,0)).to.equal(tokenAddress);

    const hardhatToken = await ethers.getContractAt("KottageToken", tokenAddress);
    
    const _owner = await hardhatToken.owner();
    const _symbol = await hardhatToken.symbol();
    const _name = await hardhatToken.name();
    const _uri = await hardhatToken.uri();

    expect(_owner).to.equal(owner.address);
    expect(_symbol).to.equal(symbol);
    expect(_name).to.equal(name);
    expect(_uri).to.equal(uri);
  });
});

