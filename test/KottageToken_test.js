const { expect } = require("chai");

function printEvent(log)
{
  if (log.eventName === "TokenMinted") {
    // Process the log
    console.log(`TokenMinted event: ${log.args[0]}, from ${log.args[1]} to ${log.args[2]}`);
  }
  else if (log.eventName === "TokenBurned") {
    console.log(`TokenBurned event: ${log.args[0]}`);
  }
  else if (log.eventName === "TokenSplit") {
    console.log(`TokenSplit event: ${log.args[0]}`);
  }
  else if (log.eventName === "Comparing") {
    console.log(`Comparing event: ${log.args[0]} and ${log.args[1]}`);
  }
}      

describe("KottageToken", function () {
  it("Deployment should create a contract with appropriate name and symbol, owner by deployer", async function () {
    const [owner] = await ethers.getSigners();

    const symbol = "TST";
    const name = "TestToken";
    const uri = "https://example.com/test.json";

    const hardhatTokenFactory = await ethers.getContractFactory("KottageToken");
    const hardhatToken = await hardhatTokenFactory.deploy(name, symbol, uri);
    const _owner = await hardhatToken.owner();
    const _symbol = await hardhatToken.symbol();
    const _name = await hardhatToken.name();
    const _uri = await hardhatToken.uri();

    expect(_owner).to.equal(owner.address);
    expect(_symbol).to.equal(symbol);
    expect(_name).to.equal(name);
    expect(_uri).to.equal(uri);
  }),
  it("Should properly mint a token and transfer it to another user", async function() {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const symbol = "TST";
    const name = "TestToken";
    const uri = "https://example.com/test.json";

    const hardhatTokenFactory = await ethers.getContractFactory("KottageToken");
    const hardhatToken = await hardhatTokenFactory.deploy(name, symbol, uri);

    // mint a token for a week: 2023-07-24-2023-07-30
    const tx = await hardhatToken.safeMint(owner.address, 1690171200, 1690689600);
    const receipt = await tx.wait();

    for (let log of receipt.logs) {
      printEvent(log);
    }

    const mintEvent = receipt.logs?.filter((x) => { return x.eventName == "TokenMinted" });
    const tokenId = mintEvent[0].args[0];
    expect(await hardhatToken.balanceOf(owner.address)).to.equal(1);

    // Transfer the token from owner to addr1
    await hardhatToken.approve(addr1.address, tokenId);
    await hardhatToken.connect(addr1).transferFrom(owner.address, addr1.address, tokenId);
    expect(await hardhatToken.balanceOf(owner.address)).to.equal(0);
    expect(await hardhatToken.balanceOf(addr1.address)).to.equal(1);

    // Transfer the token from addr1 to addr2
    await hardhatToken.connect(addr1).approve(addr2.address, tokenId);
    await hardhatToken.connect(addr2).transferFrom(addr1.address, addr2.address, tokenId);
    expect(await hardhatToken.balanceOf(addr1.address)).to.equal(0);
    expect(await hardhatToken.balanceOf(addr2.address)).to.equal(1);
  }),
  it("Should properly split a token and then merge resulting tokens", async function() {
    const [owner] = await ethers.getSigners();

    const symbol = "TST";
    const name = "TestToken";
    const uri = "https://example.com/test.json";

    // 2023-07-24-2023-07-28 and 2023-07-28-2023-07-30 encoded as UNIX timestamps
    const newRentalPeriods = [
      [
        1690171200,
        1690516800
      ],
      [
        1690516800,
        1690689600
      ],
    ];

    const tokensToMerge = [ 1, 2 ];

    const hardhatTokenFactory = await ethers.getContractFactory("KottageToken");
    const hardhatToken = await hardhatTokenFactory.deploy(name, symbol, uri);

    // mint a token for a week: 2023-07-24-2023-07-30
    const tx = await hardhatToken.safeMint(owner.address, 1690171200, 1690689600);
    const receipt = await tx.wait();

    for (let log of receipt.logs) {
      printEvent(log);
    }
  
    const mintEvent = receipt.logs?.filter((x) => { return x.eventName == "TokenMinted" });
    const tokenId = mintEvent[0].args[0];
    expect(await hardhatToken.balanceOf(owner.address)).to.equal(1);

    // let's split it into: 2023-07-24-2023-07-28 and 2023-07-28-2023-07-30
    const tx2 = await hardhatToken.split(tokenId, newRentalPeriods);
    const receipt2 = await tx2.wait();

    for (let log of receipt2.logs) {
      printEvent(log);
    }

    expect(await hardhatToken.balanceOf(owner.address)).to.equal(2);

    // let's merge it back into: 2023-07-24-2023-07-30
    const tx3 = await hardhatToken.merge(tokensToMerge);
    const receipt3 = await tx3.wait();

    for (let log of receipt3.logs) {
      printEvent(log);
    }

    expect(await hardhatToken.balanceOf(owner.address)).to.equal(1);
  });
});

