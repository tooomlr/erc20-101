pragma solidity ^0.6.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IExerciceSolution.sol";

contract TokenERC20 is ERC20, IExerciceSolution
{
    constructor(address evaluator1) public ERC20("TomToken", "pdE1B"){
        //_mint(msg.sender,767416516000000000000000000);
    }
    address[] private whitelist;
    mapping(address => bool) public isAllowed;
    mapping(address => uint) public level;

    function symbol() public override(ERC20, IExerciceSolution) view returns (string memory){
        return "pdE1B";
    }
    function getToken() external override returns (bool){
        require(isAllowed[msg.sender] == true);
        _mint(msg.sender,1);
        return true;

    }
    function buyToken() external override payable returns (bool){
        require(isAllowed[msg.sender] == true);
        if (level[msg.sender] == 1) {
            _mint(msg.sender, msg.value);
        }
        else if (level[msg.sender] == 2) {
            _mint(msg.sender, 2 * msg.value);
        }
        else {
            _mint(msg.sender, 1);
        }

        return true;
    }
    function isCustomerWhiteListed(address customerAddress) external override returns (bool){
        isAllowed[customerAddress] = true;
        return true;
    }
    function customerTierLevel(address customerAddress) external override returns (uint256){
        level[customerAddress] = 2;
        return 2;
    }
}