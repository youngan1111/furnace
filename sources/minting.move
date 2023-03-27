// Module defining the CoinType for hello_blockchain's test coins.
module hello_blockchain::minting {
    use aptos_framework::coin;
    use aptos_framework::coin::{BurnCapability, MintCapability, FreezeCapability};
    use std::string;
    use std::signer::address_of;
    use std::signer;

    // Errors.
    const ERR_NOT_ADMIN: u64 = 1;

    // Used in documentation.
    struct QVE {}
    struct QVECap has key {
        burn: BurnCapability<QVE>,
        mint: MintCapability<QVE>,
        freeze: FreezeCapability<QVE>,
    }

    public entry fun create_qve(owner: &signer) {
        assert!(signer::address_of(owner) == @hello_blockchain, ERR_NOT_ADMIN);
        let (
            burn,
            freeze,
            mint
        ) = coin::initialize<QVE>(
            owner,
            string::utf8(b"QVE Protocol"),
            string::utf8(b"QVE"),
            8,
            true
        );
        move_to(owner, QVECap {
            burn,
            freeze,
            mint,
        });
    }

    public entry fun mint_qve(dest: &signer, amt: u64) acquires QVECap {
        let cap = borrow_global_mut<QVECap>(@hello_blockchain);
        let minted = coin::mint(amt, &cap.mint);
        coin::deposit(address_of(dest), minted);
    }
}