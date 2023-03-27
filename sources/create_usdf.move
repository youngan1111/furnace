// Module defining the CoinType for hello_blockchain's test coins.
module hello_blockchain::usdf {
    use aptos_framework::coin;
    use aptos_framework::coin::{BurnCapability, MintCapability, FreezeCapability};
    use std::string;
    use std::signer::address_of;
    use std::signer;

    // Errors.
    const ERR_NOT_ADMIN: u64 = 1;

    // Used in documentation.
    struct USDF {}

    struct USDFCap has key {
        burn: BurnCapability<USDF>,
        mint: MintCapability<USDF>,
        freeze: FreezeCapability<USDF>,
    }

    public entry fun create_usdf(owner: &signer) {
        assert!(signer::address_of(owner) == @hello_blockchain, ERR_NOT_ADMIN);
        let (
            burn,
            freeze,
            mint
        ) = coin::initialize<USDF>(
            owner,
            string::utf8(b"Ferum USD"),
            string::utf8(b"USDF"),
            8,
            true
        );
        move_to(owner, USDFCap {
            burn,
            freeze,
            mint,
        });
    }

    public entry fun mint_usdf(dest: &signer, amt: u64) acquires USDFCap {
        let cap = borrow_global_mut<USDFCap>(@hello_blockchain);
        let minted = coin::mint(amt, &cap.mint);
        coin::deposit(address_of(dest), minted);
    }
}