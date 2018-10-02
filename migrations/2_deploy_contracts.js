const Donatocracy = artifacts.require('Donatocracy');

module.exports = async function (deployer) {
    deployer.deploy(Donatocracy);
};
