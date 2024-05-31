import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { BigNumber } from "ethers";
import { ethers, network } from "hardhat";
import { tokenName, tokenSymbol } from "../payrollConstructor/arguments";

describe("Payroll", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployPayrollFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, employee, funder] = await ethers.getSigners();

    const Payroll = await ethers.getContractFactory("Payroll");
    Payroll.connect(owner);
    const initialCapital = 1000;
    const tokenRatioToEther = 1;
    const payroll = await Payroll.deploy(tokenName, tokenSymbol, initialCapital.toString(), tokenRatioToEther);

    const receipt = await payroll.deployed();
    console.log(`Payroll contract deployed at ${receipt.address}`);

    const paymentTokenAddress = await payroll.paymentToken();
    console.log(`paymentToken address`, paymentTokenAddress);

    const PayrollToken = await ethers.getContractFactory("PayrollToken");
    const payrollToken = PayrollToken.attach(paymentTokenAddress);

    return { payrollToken, payroll, initialCapital, owner, employee, funder };
  }

  describe("Deployment", function () {
    it("Should set the right arguments", async function () {
      const { payroll, initialCapital, owner } = await loadFixture(deployPayrollFixture);
      const tokenBalance = await payroll.tokenBalance();
      console.log(`Token balance ${tokenBalance}`);
      expect(tokenBalance).to.equal(initialCapital);

      const companyAcc = await payroll.companyAcc();
      console.log(`Company account ${companyAcc}`);
      expect(companyAcc).to.equal(owner.address);
    });

    it("Should fund company product with 1 Ether", async function () {
      const { payrollToken, payroll, employee } = await loadFixture(deployPayrollFixture);

      const fundCompanyWithEther = await payroll.fundCompanyWithEther({ value: 1 });
      console.log(`Company funded with 1 ether`);
      const getCompanyEtherBalance = await payroll.getCompanyEtherBalance();
      expect(getCompanyEtherBalance).to.equal(1);
      console.log(`Company ether balance with ${getCompanyEtherBalance} ether`);
    });
    
    it("Should trigger fund event when funding company", async function () {
      const { payrollToken, payroll, employee } = await loadFixture(deployPayrollFixture);

      const fundCompanyWithEther = await payroll.fundCompanyWithEther({ value: 1 });

      const getCompanyEtherBalance = await payroll.getCompanyEtherBalance();
      expect(getCompanyEtherBalance).to.equal(1);
      expect(getCompanyEtherBalance).to.emit(payroll, "Fund").withArgs({ value: 1 });

      console.log(`Triggered funded event`);
      console.log(`Company ether balance with ${getCompanyEtherBalance} ether`);
    });

    it("Should add 1 employee, and confirm employee details", async function () {
      const { payroll, employee } = await loadFixture(deployPayrollFixture);
      const employeeSalary = 1000;
      const addEmployee = await payroll.addEmployee(employee.address, employeeSalary);
      console.log(`1 employee added with payment address ${employee.address} and salary ${employeeSalary}`);

      let totalEmployees = await payroll.totalEmployees();
      expect(totalEmployees).to.equal(1);
      console.log(`Total Employees ${totalEmployees}`);

      const getEmployees = await payroll.getEmployees();
      expect(getEmployees[0][0]).to.equal(employee.address);
      console.log(`Employee payment address ${getEmployees[0][0]}`);
      expect(getEmployees[0][1]).to.equal(employeeSalary);
      console.log(`Employee salary ${getEmployees[0][1]}`);
      expect(getEmployees[0][2]).to.equal(0);
      console.log(`Employee Last payment ${getEmployees[0][2]}`);
      expect(getEmployees[0][3]).to.equal(0);
      console.log(`Employee payment count ${getEmployees[0][3]}`);
    });

    it("Should get 1 token for 1 eth", async function () {
      const { payrollToken, payroll, initialCapital, owner, employee, funder } = await loadFixture(deployPayrollFixture);

      let tokenBalance = await payroll.tokenBalance();
      console.log(`Token balance before funding: ${tokenBalance}`);
      expect(tokenBalance).to.equal(initialCapital);

      const fundAmount = 100;
      const fundCompanyWithEther = await payroll.fundCompanyWithEther({ value: fundAmount });

      let getCompanyEtherBalance = await payroll.getCompanyEtherBalance();
      console.log(`Ether balance before clientGetEthPayTokens: ${getCompanyEtherBalance}`);
      expect(getCompanyEtherBalance).to.equal(fundAmount);

      const clientGetEthPayTokens = await payroll.clientGetEthPayTokens(fundAmount);

      getCompanyEtherBalance = await payroll.getCompanyEtherBalance();
      console.log(`Ether balance after clientGetEthPayTokens: ${getCompanyEtherBalance}`);
      expect(getCompanyEtherBalance).to.equal(0);

      tokenBalance = await payroll.tokenBalance();
      console.log(`Token balance after clientGetEthPayTokens: ${tokenBalance}`);
      const currentSupply = initialCapital + fundAmount;
      expect(tokenBalance).to.equal(currentSupply);
    });

    it("Employee should claim his salary", async function () {
      const { payrollToken, payroll, initialCapital, owner, employee, funder } = await loadFixture(deployPayrollFixture);

      const employeeSalary = 1000;
      const addEmployee = await payroll.addEmployee(employee.address, employeeSalary);

      let employeeBalance = await payroll.connect(employee).employeeTokenBalance();
      console.log(`Employee token balance before claim his salary ${employeeBalance}`);
      expect(employeeBalance).to.equal(0);

      const claim = await payroll.connect(employee).claim();

      employeeBalance = await payroll.connect(employee).employeeTokenBalance();
      console.log(`Employee token balance after claim his salary ${employeeBalance}`);
      expect(employeeBalance).to.equal(employeeSalary);
    });
    
    it("Employee claim should trigger Paid event", async function () {
      const { payrollToken, payroll, initialCapital, owner, employee, funder } = await loadFixture(deployPayrollFixture);

      const employeeSalary = 1000;
      const addEmployee = await payroll.addEmployee(employee.address, employeeSalary);

      const claim = await payroll.connect(employee).claim();
      expect(claim).to.emit(payroll, "Paid").withArgs();
      console.log("Paid event to be triggered  after employee claim");
    });

    it("Employee fails to claim salary because has not been added as an employee by owner", async function () {
      const { payrollToken, payroll, initialCapital, owner, employee, funder } = await loadFixture(deployPayrollFixture);
      await expect(payroll.connect(employee).claim()).to.be.revertedWith("The employee couldn't found");
    });
    
    it("Employee should get approval and stake his salary", async function () {
      const { payrollToken, payroll, initialCapital, owner, employee, funder } = await loadFixture(deployPayrollFixture);

      const employeeSalary = 1000;
      const addEmployee = await payroll.addEmployee(employee.address, employeeSalary);

      const claim = await payroll.connect(employee).claim();

      let employeeBalance = await payrollToken.connect(employee).balanceOf(employee.address);
      console.log(`Employee has balance of ${employeeBalance} after claim his salary`);
      expect(employeeBalance).to.equal(employeeSalary);

      const approve = await payrollToken.connect(employee).approve(payroll.address, employeeSalary);
      console.log(`approve address of ${payroll.address} company contract to spend employee salary ${employeeSalary} of the employee address ${employee.address}`);

      const allowance = await payrollToken.allowance(employee.address, payroll.address);
      console.log(`company address ${payroll.address} has the allowance to spend ${allowance} from employee address ${employee.address}`);

      let stake = await payroll.connect(employee).stake(employeeSalary / 2);
      let getStake = await payroll.stakes([1]);
      expect(getStake[0]).to.equal(1);

      stake = await payroll.connect(employee).stake(employeeSalary / 2);
      getStake = await payroll.stakes([2]);
      expect(getStake[0]).to.equal(2);

      employeeBalance = await payrollToken.connect(employee).balanceOf(employee.address);
      console.log(`Employee has balance of ${employeeBalance} after staking his salary`);
      expect(employeeBalance).to.equal(0);

      let activeStake = await payroll.activeStakes([0]);
      expect(activeStake.stakeId).to.equal(1);
      expect(activeStake.amount).to.equal(employeeSalary / 2);

      activeStake = await payroll.activeStakes([1]);
      expect(activeStake.stakeId).to.equal(2);
      expect(activeStake.amount).to.equal(employeeSalary / 2);

      const getEmployeeStakes = await payroll.connect(employee).getEmployeeStakes();
    });

    it("Employee should unstake with interest", async function () {
      const { payrollToken, payroll, initialCapital, owner, employee, funder } = await loadFixture(deployPayrollFixture);

      const fundAmount = 1000;
      const fundCompanyWithEther = await payroll.fundCompanyWithEther({ value: fundAmount });

      let getCompanyEtherBalance = await payroll.getCompanyEtherBalance();
      expect(getCompanyEtherBalance).to.equal(fundAmount);

      const clientGetEthPayTokens = await payroll.clientGetEthPayTokens(fundAmount);

      const employeeSalary = 1000;
      const addEmployee = await payroll.addEmployee(employee.address, employeeSalary);
      const claim = await payroll.connect(employee).claim();
      const approve = await payrollToken.connect(employee).approve(payroll.address, employeeSalary);
      const allowance = await payrollToken.allowance(employee.address, payroll.address);

      let latestBlock = await ethers.provider.getBlock("latest");
      console.log(`latest block number ${latestBlock.timestamp} before stake`);

      const stake = await payroll.connect(employee).stake(employeeSalary);
      const getStake = await payroll.stakes([1]);
      expect(getStake[0]).to.equal(1);

      latestBlock = await ethers.provider.getBlock("latest");
      console.log(`latest block timestamp ${latestBlock.timestamp} after stake`);

      let employeeBalance = await payrollToken.connect(employee).balanceOf(employee.address);
      console.log(`Employee has balance of ${employeeBalance} after staking`);
      expect(employeeBalance).to.equal(0);

      const activeStake = await payroll.activeStakes([0]);
      expect(activeStake.stakeId).to.equal(1);
      expect(activeStake.amount).to.equal(employeeSalary);

      const stakeId = 1;
      const unstake = await payroll.connect(employee).unstake(stakeId);

      latestBlock = await ethers.provider.getBlock("latest");
      console.log(`latest block timestamp ${latestBlock.timestamp} after unstake`);

      employeeBalance = await payrollToken.connect(employee).balanceOf(employee.address);
      console.log(`Employee has balance of ${employeeBalance} after unstaking`);
      const interest = 1000 / 10;
      expect(employeeBalance).to.equal(1000 + interest);

      const getEmployeeStakes = await payroll.connect(employee).getEmployeeStakes();
    });

    it("Employee should unstake only capital without interest", async function () {
      const { payrollToken, payroll, initialCapital, owner, employee, funder } = await loadFixture(deployPayrollFixture);

      const tokenBalance = await payroll.tokenBalance();
      console.log(`New Token balance ${tokenBalance}`);
      expect(tokenBalance).to.equal(1000);

      const employeeSalary = 1000;
      const addEmployee = await payroll.addEmployee(employee.address, employeeSalary);
      const claim = await payroll.connect(employee).claim();
      const approve = await payrollToken.connect(employee).approve(payroll.address, employeeSalary);
      const allowance = await payrollToken.allowance(employee.address, payroll.address);

      let latestBlock = await ethers.provider.getBlock("latest");
      console.log(`latest block number ${latestBlock.timestamp} before stake`);

      const stake = await payroll.connect(employee).stake(employeeSalary);
      const getStake = await payroll.stakes([1]);
      expect(getStake[0]).to.equal(1);

      latestBlock = await ethers.provider.getBlock("latest");
      console.log(`latest block number ${latestBlock.timestamp} after stake`);

      let employeeBalance = await payrollToken.connect(employee).balanceOf(employee.address);
      console.log(`Employee has balance of ${employeeBalance} after staking`);
      expect(employeeBalance).to.equal(0);

      const activeStake = await payroll.activeStakes([0]);
      expect(activeStake.stakeId).to.equal(1);
      expect(activeStake.amount).to.equal(employeeSalary);

      const stakeId = 1;
      const unstake = await payroll.connect(employee).unstake(stakeId);

      latestBlock = await ethers.provider.getBlock("latest");
      console.log(`latest block number ${latestBlock.timestamp} after unstake`);

      employeeBalance = await payrollToken.connect(employee).balanceOf(employee.address);
      console.log(`Employee has balance of ${employeeBalance} after unstaking`);
      expect(employeeBalance).to.equal(employeeSalary);

      const getEmployeeStakes = await payroll.connect(employee).getEmployeeStakes();
      console.log(getEmployeeStakes);
    });

    it("Should update employee salary", async function () {
      const { payrollToken, payroll, initialCapital, owner, employee, funder } = await loadFixture(deployPayrollFixture);

      const employeeSalary = 1000;
      const addEmployee = await payroll.addEmployee(employee.address, employeeSalary);

      const newSalary = 2000;
      const updateEmployeeSalary = await payroll.connect(owner).updateEmployeeSalary(employee.address, newSalary.toString());

      const employeeUpdated = await payroll.employeesAddress(employee.address);
      expect(employeeUpdated[1]).to.equal(newSalary);
      console.log(`Employee salary updated to ${employeeUpdated[1]}`);

      const getEmployees = await payroll.getEmployee(employee.address);
      console.log(`Employee payment address ${getEmployees[0]}`);
      console.log(`Employee salary ${getEmployees[1]}`);
      console.log(`Employee Last payment ${getEmployees[2]}`);
      console.log(`Employee payment count ${getEmployees[3]}`);
    });

    it("Should pay an employee", async function () {
      const { payrollToken, payroll, initialCapital, owner, employee, funder } = await loadFixture(deployPayrollFixture);

      const employeeSalary = 1000;
      const addEmployee = await payroll.addEmployee(employee.address, employeeSalary);

      const payAnEmployee = await payroll.payAnEmployee(employee.address, employeeSalary);
      console.log(`Pay employee with address ${employee.address} at hash ${payAnEmployee.hash}`);

      const tokenBalance = await payroll.tokenBalance();
      console.log(`New Token balance after pay employee  ${tokenBalance}`);
      expect(tokenBalance).to.equal(0);

      const employeeBalance = await payrollToken.connect(employee).balanceOf(employee.address);
      console.log(`${employee.address} has balance of ${employeeBalance}`);
      expect(employeeBalance).to.equal(employeeSalary);

      payroll.connect(owner);
      let totalSalary = await payroll.totalSalaries();
      expect(totalSalary).to.equal(employeeSalary);
      console.log(`Token Salaries ${totalSalary}`);
    });
    
    it("Company owner should trigger Paid event when pay an employee", async function () {
      const { payrollToken, payroll, initialCapital, owner, employee, funder } = await loadFixture(deployPayrollFixture);

      const employeeSalary = 1000;
      const addEmployee = await payroll.addEmployee(employee.address, employeeSalary);

      const payAnEmployee = await payroll.payAnEmployee(employee.address, employeeSalary);
      expect(payAnEmployee).to.emit(payroll, "Paid").withArgs(employee.address, employeeSalary);

      console.log("Paid event to be triggered  after pay an claim");
    });

    it("Should remove an employee", async function () {
      const { payrollToken, payroll, initialCapital, owner, employee, funder } = await loadFixture(deployPayrollFixture);

      const employeeSalary = 1000;
      const addEmployee1 = await payroll.addEmployee(employee.address, employeeSalary);

      const addEmployee2 = await payroll.addEmployee(funder.address, employeeSalary);

      const addEmployee3 = await payroll.addEmployee(owner.address, employeeSalary);

      const removeEmployee = await payroll.removeEmployee(employee.address);

      const totalEmployees = await payroll.totalEmployees();
      expect(totalEmployees).to.equal(2);
      console.log(`Total Employees ${totalEmployees}`);
    });

    it("Should close company", async function () {
      const { payrollToken, payroll, initialCapital, owner } = await loadFixture(deployPayrollFixture);

      expect(await payroll.tokenBalance()).to.equal(initialCapital);
      expect(await payroll.companyAcc()).to.equal(owner.address);

      let paymentToken = await payroll.paymentToken();
      expect(paymentToken).to.not.equal("0x0000000000000000000000000000000000000000");
      console.log(`Payment Token ${paymentToken}`);

      const shutDownCompany = await payroll.closeCompany();
      console.log(`Closed company at hash ${shutDownCompany.hash}`);

      const tokenBalanceOfOwner = await payrollToken.balanceOf(owner.address);
      expect(tokenBalanceOfOwner).to.equal(initialCapital);
      console.log(`Balance of company owner account ${owner.address} has ${tokenBalanceOfOwner} tokens after company closed`);
    });
  });
});