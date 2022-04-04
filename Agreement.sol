//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// Creates new Contracts for each Document
contract AgreementFactory {

    address public owner;
    // keep track of the deployed contracts
    Agreement[] public agreements;
    // emitted when new contract is created
    event AgreementCreated(bytes32 indexed _document, address _issuer, address _contractAddress);

    constructor() {
        owner = msg.sender;
    }
    // @dev - create new contract with document hash and issuers signature
    // stores the deployed contract address in agreements[]
    // emit the event
    function newAgreement(bytes32 _documentHash, bytes memory _issuerSignature) external {
        Agreement agree = new Agreement(_documentHash, msg.sender, _issuerSignature);
        agreements.push(agree);
        emit AgreementCreated(_documentHash, msg.sender, address(agree));
    }
}

contract Agreement {

    bytes32 public documentHash;
    address public issuer;
    uint256 public creationTime;

    mapping(address => bytes) public signatures;
    mapping(address => uint256) timeStamps;
    mapping(address => bool) allowedUsers;
    address[] public signers;

    event userSigned(address _user, uint _timeStamp);

    constructor(
        bytes32 _documentHash, 
        address _issuer, 
        bytes memory _issuerSignature ) {

        documentHash = _documentHash;
        issuer = _issuer;
        signatures[issuer] = _issuerSignature;
        signers.push(issuer);
        allowedUsers[issuer] = true;
        creationTime = block.timestamp;
        timeStamps[issuer] = creationTime;
    }

    // only contract issuer can access the functions
    modifier onlyIssuer() {
        require(issuer == msg.sender, "only Issuer");
        _;
    }

    // promote user to allowedUser
    function allowUser(address _user) external onlyIssuer {
        allowedUsers[_user] = true;
    }

    // only allowed users can acess the functions
    modifier onlyAllowed() {
        require(allowedUsers[msg.sender], "user notAllowed");
        _;
    }

    // @dev - allowedUsers can Sign the Document
    // Takes the signature as input and records it
    // checks if the user has already signed the doc
    // records the timestamp of the signature
    // emits the userSigned event
    function signDoc(bytes memory _signature) public onlyAllowed {
        require(!(checkUserSign(msg.sender)), "already signed");
        signers.push(msg.sender);
        signatures[msg.sender] = _signature;
        timeStamps[msg.sender] = block.timestamp;

        emit userSigned(msg.sender, block.timestamp);
    }

    // checks if the user has signed earlier
    function checkUserSign(address _signer)
        internal view returns(bool) {
        return (timeStamps[_signer] > 0) ? true : false;
    }

    // @dev - Verifies the signature of a user
    // resolves their signature and derives a public key
    // returns a verification and timestamp
    function verifySignature (address _signee) 
        public returns (bool, uint) {

        bytes32 ethSignMsgHash = getEthSignMsgHash(documentHash);

        if(recoverPublicKey(ethSignMsgHash, signatures[_signee]) == _signee) {
            return (true, timeStamps[_signee]);
        } else {
            return (false, 0);
        }
    }

    // Hashes a message in ethereum style
    function getEthSignMsgHash(bytes32 _documentHash) 
        internal pure returns(bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _documentHash));
    }

    // @dev - resolves the signature with v,r & s and derives the public key
    function recoverPublicKey(bytes32 _ethSignMsgHash, bytes memory _signature)
        internal pure returns(address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignMsgHash, v, r, s);
    }

    // @dev - splits the signature into 3 parts 
    function splitSignature(bytes memory _sig)
        internal pure returns(bytes32 r, bytes32 s, uint8 v) {

        require(_sig.length == 65, "Invalid signature length or not Signed");
        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
    }
}
