pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./ERC20TD.sol";
import "./IExerciceSolution.sol";

contract Evaluator 
{

	mapping(address => bool) public teachers;
	ERC20TD TDERC20;

	uint256[20] private randomSupplies;
	string[20] private randomTickers;
 	uint public nextValueStoreRank;

 	mapping(address => string) public assignedTicker;
 	mapping(address => uint256) public assignedSupply;
 	mapping(address => mapping(uint256 => bool)) public exerciceProgression;
 	mapping(address => IExerciceSolution) public studentErc20;
 	mapping(address => uint256) public ex8Tier1AmountBought;

	constructor(ERC20TD _TDERC20) 
	public 
	{
		TDERC20 = _TDERC20;
	}

	fallback () external payable 
	{}

	receive () external payable 
	{}

	function setRandomTickersAndSupply(uint256[20] memory _randomSupplies, string[20] memory _randomTickers) 
	public 
	onlyTeachers
	{
		randomSupplies = _randomSupplies;
		randomTickers = _randomTickers;
		nextValueStoreRank = 0;
	}

	function ex1_getTickerAndSupply()
	public
	{
		assignedSupply[msg.sender] = randomSupplies[nextValueStoreRank];
		assignedTicker[msg.sender] = randomTickers[nextValueStoreRank];
		nextValueStoreRank += 1;

		// Crediting points
		if (!exerciceProgression[msg.sender][1])
		{
			exerciceProgression[msg.sender][1] = true;
			TDERC20.distributeTokens(msg.sender, 1);
		}
	}

	function ex2_testErc20TickerAndSupply(IExerciceSolution erc20ToTest)
	public
	{
		// Checking ticker and supply were received
		require(exerciceProgression[msg.sender][1]);

		// Assigning passed ERC20 as student ERC20
		studentErc20[msg.sender] = erc20ToTest;

		// Checking ticker was set properly
		require(_compareStrings(assignedTicker[msg.sender], erc20ToTest.symbol()), "Incorrect ticker");
		// Checking supply was set properly
		require(assignedSupply[msg.sender] == erc20ToTest.totalSupply(), "Incorrect supply");
		// Checking some ERC20 functions were created
		require(erc20ToTest.allowance(address(this), msg.sender) == 0, "Allowance not implemented or incorrectly set");
		require(erc20ToTest.balanceOf(address(this)) == 0, "BalanceOf not implemented or incorrectly set");
		require(erc20ToTest.approve(msg.sender, 10), "Approve not implemented");

		// Crediting points
		if (!exerciceProgression[msg.sender][2])
		{
			exerciceProgression[msg.sender][2] = true;
			// Setup points
			TDERC20.distributeTokens(msg.sender, 3);
			// Creating ERC20
			TDERC20.distributeTokens(msg.sender, 2);
			// Deploying ERC20
			TDERC20.distributeTokens(msg.sender, 2);
		}

	}

	function ex3_testGetToken()
	public
	{
		// Checking ERC20 was created
		require(address(studentErc20[msg.sender]) != address(0), "Student ERC20 not registered");

		// Retrieving initial balance
		uint256 initialBalance = studentErc20[msg.sender].balanceOf(address(this));

		// Call getToken
		studentErc20[msg.sender].getToken();

		// Retrieving final balance
		uint256 finalBalance = studentErc20[msg.sender].balanceOf(address(this));

		require(initialBalance < finalBalance, "Token balance did not increase");

		if (!exerciceProgression[msg.sender][3])
		{
			exerciceProgression[msg.sender][3] = true;
			// Distribute points
			TDERC20.distributeTokens(msg.sender, 2);

		}
	}

	function ex4_testBuyToken()
	public
	{

		_testBuyToken();

		if (!exerciceProgression[msg.sender][4])
		{
			exerciceProgression[msg.sender][4] = true;
			// Distribute points
			TDERC20.distributeTokens(msg.sender, 2);
		}
	}

	function ex5_testDenyListing()
	public
	{
		// Checking ERC20 was created
		require(address(studentErc20[msg.sender]) != address(0), "Student ERC20 not registered");

		require(!studentErc20[msg.sender].isCustomerWhiteListed(address(this)));

		bool wasBuyAccepted = true;
		try studentErc20[msg.sender].getToken() returns (bool v) 
		{
			wasBuyAccepted = v;
        } 
        catch 
        {
            // This is executed in case revert() was used.
            wasBuyAccepted = false;
        }

        require(!wasBuyAccepted);

        if (!exerciceProgression[msg.sender][5])
		{
			exerciceProgression[msg.sender][5] = true;
			// Distribute points
			TDERC20.distributeTokens(msg.sender, 1);
		}
	}

	function ex6_testAllowListing()
	public
	{
		// Checking ERC20 was created
		require(address(studentErc20[msg.sender]) != address(0), "Student ERC20 not registered");
		// Checking ex5 was done
		require(exerciceProgression[msg.sender][5]);

		// Check if the current contract is whitelisted
		require(studentErc20[msg.sender].isCustomerWhiteListed(address(this)));

		// Trying to buy
		ex3_testGetToken();

        if (!exerciceProgression[msg.sender][6])
		{
			exerciceProgression[msg.sender][6] = true;
			// Distribute points
			TDERC20.distributeTokens(msg.sender, 2);
		}
	}

	function ex7_testDenyListing()
	public
	{
		// Checking ERC20 was created
		require(address(studentErc20[msg.sender]) != address(0), "Student ERC20 not registered");

		require(!studentErc20[msg.sender].isCustomerWhiteListed(address(this)));

		require(studentErc20[msg.sender].customerTierLevel(address(this)) == 0);

		bool wasBuyAccepted = true;
		try studentErc20[msg.sender].buyToken.value(0.0001 ether)() returns (bool v) 
		{
			wasBuyAccepted = v;
        } 
        catch 
        {
            // This is executed in case revert() was used.
            wasBuyAccepted = false;
        }

        require(!wasBuyAccepted);

        if (!exerciceProgression[msg.sender][7])
		{
			exerciceProgression[msg.sender][7] = true;
			// Distribute points
			TDERC20.distributeTokens(msg.sender, 1);
		}
	}

	function ex8_testTier1Listing()
	public
	{
		// Checking ERC20 was created
		require(address(studentErc20[msg.sender]) != address(0), "Student ERC20 not registered");
		// Checking ex7 was done
		require(exerciceProgression[msg.sender][7]);

		// Check if the current contract is whitelisted
		require(studentErc20[msg.sender].isCustomerWhiteListed(address(this)));

		// Check if the current contract has the correct tier level
		require(studentErc20[msg.sender].customerTierLevel(address(this)) == 1);

		// Trying to buy
		ex8Tier1AmountBought[msg.sender] = _testBuyToken();

        if (!exerciceProgression[msg.sender][8])
		{
			exerciceProgression[msg.sender][8] = true;
			// Distribute points
			TDERC20.distributeTokens(msg.sender, 2);
		}
	}

	function ex9_testTier2Listing()
	public
	{
		// Checking ERC20 was created
		require(address(studentErc20[msg.sender]) != address(0), "Student ERC20 not registered");
		// Checking ex7 was done
		require(exerciceProgression[msg.sender][7]);

		// Check if the current contract is whitelisted
		require(studentErc20[msg.sender].isCustomerWhiteListed(address(this)));

		// Check if the current contract has the correct tier level
		require(studentErc20[msg.sender].customerTierLevel(address(this)) == 2);

		// Trying to buy
		uint256 tier2AmountBought = _testBuyToken();

		// Checking that bought amount is twice what was bought before, for the same price
		require(tier2AmountBought == 2 * ex8Tier1AmountBought[msg.sender]);


        if (!exerciceProgression[msg.sender][9])
		{
			exerciceProgression[msg.sender][9] = true;
			// Distribute points
			TDERC20.distributeTokens(msg.sender, 2);
		}
	}


	/* Internal functions and modifiers */ 


	modifier onlyTeachers() 
	{

	    require(TDERC20.teachers(msg.sender));
	    _;
	}

	function _compareStrings(string memory a, string memory b) 
	internal 
	pure 
	returns (bool) 
	{
    	return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
	}

	function _testBuyToken()
	internal
	returns(uint256 firstBuyAmount)
	{
				// Checking ERC20 was created
		require(address(studentErc20[msg.sender]) != address(0), "Student ERC20 not registered");

		// Retrieving initial balance
		uint256 initialBalance = studentErc20[msg.sender].balanceOf(address(this));

		// Call buyToken
		studentErc20[msg.sender].buyToken.value(0.0001 ether)();

		// Retrieving intermediate balance
		uint256 intermediateBalance = studentErc20[msg.sender].balanceOf(address(this));

		require(initialBalance < intermediateBalance, "Token balance did not increase");

		firstBuyAmount = intermediateBalance - initialBalance;

		// Call buyToken again
		studentErc20[msg.sender].buyToken.value(0.0003 ether)();

		// Retrieving final balance
		uint256 finalBalance = studentErc20[msg.sender].balanceOf(address(this));

		require(intermediateBalance < finalBalance, "Token balance did not increase");

		uint256 secondBuyAmount = finalBalance - intermediateBalance;

		// Check that second buy amount was a different amount that first buy amount

		require(secondBuyAmount > firstBuyAmount, "Second buy amount lower than first");
	}



}