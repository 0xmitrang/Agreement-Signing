# Agreement-Signing
Build a Smart Contract for Agreement Signing

This smart contract is for developing an Agreement Signing mechanism. An agreement signing mechanism is useful when two or more parties come to terms on something together and sign a legal document for the same.

In this article, we will discuss this use case and also code the business logic of this Agreement Signing mechanism in a Smart Contract. Let us take an example of a Startup that is signing agreements with new employees and wants to do this in a decentralized way.

Just to make it simpler, let us first understand a simple workflow:

The Document Issuing Company will undergo the following steps.
- Encrypt the Document and upload it to IPFS or similar decentralized storage.
- Hash the document, and sign the DocumentHash(off-chain).
- Use the agreementFactory contract (signing service provider) to create a dedicated smart contract for their document which will take Document Hash and Issuer Signature as the inputs.

For sharing this with new employees:
- Will encrypt the Document with their own private key first.
- Then encrypt it using an Employee's Public Key and send them off-chain.

At the Receivers/Employee's End
- They will first decrypt the message using their private key.
- Then again decrypt the message using the company's public key.
- The Employee now has the access to the document and can hash it and check the Document Hash in the Agreement Contract for checking the Integrity.
- The employee can now sign the document hash using their private key and Metamask(off-chain). Make the signature entry in the Agreement Smart Contract with signDoc Function.

Now anyone can view/verify all the signatures(including the issuer's sign) from the agreement smart contract. You can also build a frontend around this contract to build a full working project.
