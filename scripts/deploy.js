const hre = require("hardhat");

async function main(){
    const Lock = await hre.ethers.getContractFactory("Lock");
    const Lock = await Lock.deploy();

    await Lock.deployed();
    
    console.log(
        'Lock with ! ETH and unlock timestamp${unlockTime} deployed to ${lock.address}'
    
    );

}

main().catch((error)=> {
    console.error(error);
    process.exitCode = 1;
}); 