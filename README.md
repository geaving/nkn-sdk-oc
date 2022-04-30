# nkn-sdk-oc
Objective-C Implementation of NKN Client and Wallet SDK

## Usage

### import

```objective-c
#import "Nkn.framework/Headers/Nkn.objc.h"
#import <NetworkExtension/NetworkExtension.h>
```

### interface

```objective-c
@interface ViewController ()<NknOnMessageFunc, NknOnConnectFunc>
{
}
@end

- (void)onConnect:(NknNode *)p0 {
    //do something
    NSLog(@"onConnect: opened");
}

- (void)onMessage:(NknMessage *)p0 {
    //do something
    NSLog(@"message received from %@, data: %@", p0.src, [[NSString alloc] initWithData:p0.data encoding:NSUTF8StringEncoding]);
}
```

### Client

By default the client will use bootstrap RPC server (for getting node address) provided by NKN

```objective-c
NknClientConfig *conf = [NknClientConfig new];
```

Any NKN full node can serve as a bootstrap RPC server. To create a client using customized bootstrap RPC server

```objective-c
[conf setSeedRPCServerAddr:[[NkngomobileStringArray alloc] initFromString:@"https://ip:port"]];
```

Create a account using an existing secret seed

```objective-c
NknAccount *account = [[NknAccount alloc] init:[@"70016750081905799396851717434796" dataUsingEncoding:NSUTF8StringEncoding]];
```

Create a client by account using id(any string or nil) and config

```objective-c
NknClient *client = [[NknClient alloc] init:account identifier:@"client A" config:conf];
```

Listen for connection

```objective-c
[client.onConnect setCallback:self]
```

Receive data from other clients

```objective-c
[client.onMessage setCallback:self];
```

Send a text message to other client

```objective-c
NSError *error;
[client sendText:[[NkngomobileStringArray alloc] initFromString:@"address"] data:@"Hello, I am client..." config:nil error:&error];
if (error != nil) {
    //do something
    NSLog(@"send message fail: %@", error.description);
}
```
In any case, you should handle error exceptions, including the following examples

### Multiclient

Create a multiclient by account with 3 sub client

```objective-c
NknMultiClient *multiClient = [[NknMultiClient alloc] init:account baseIdentifier:nil numSubClients:3 originalClient:true config:conf];
```

Same as client

```objective-c
[multiClient.onConnect setCallback:self];
[multiClient.onMessage setCallback:self];
```

multiClient send a text message to other client

```objective-c
[multiClient sendText:[[NkngomobileStringArray alloc] initFromString:@"address" data:@"Hello, I am multiClient..." config:nil error:nil];
```

### Wallet

By default the wallet will use RPC server provided by nkn.org

```objective-c
NknWalletConfig *walletConf = [NknWalletConfig new];
walletConf.password = @"abc123";
```

Any NKN full node can serve as a RPC server. To create a wallet using customized RPC server

```objective-c
walletConf.seedRPCServerAddr = [[NkngomobileStringArray alloc] initFromString:@"https://ip:port"];
```

Create a wallet

```objective-c
NknWallet *wallet = [[NknWallet alloc] init:accountA config:walletConf];
```

Export wallet to JSON string, where sensitive contents are encrypted by password provided in config

```objective-c
NSLog(@"wallet to JSON string: %@", [wallet toJSON:nil]);
```

Verify password of the wallet

```objective-c
if ([wallet verifyPassword:@"abc123" error:nil]) {
    NSLog(@"provided password is the correct password of this wallet");
}
```

Query asset balance with background context

```objective-c
NSLog(@"balance: %@", [wallet balance:nil].string);
```

Query asset balance for address

```objective-c
NSLog(@"balance: %@", [wallet balanceByAddress:@"NKNxxxxx" error:nil].string);
```

Create a transaction config, you can set fee or nonce or other attributes

```objective-c
NknTransactionConfig *transferConf = [NknTransactionConfig new];
transferConf.fee = @"0.01";
```

Transfer asset to some address

```objective-c
NSString *txnHash = [wallet transfer:accountA.walletAddress amount:@"100" config:transferConf error:nil];
```

Open nano pay channel to specified address

```objective-c
NknNanoPay *nanoPay = [wallet newNanoPay:@"NKNxxxxx" fee:@"0.01" duration:4320 error:nil];
```

Increment channel balance by 100 NKN

```objective-c
TransactionTransaction *txn = [nanoPay incrementAmount:@"100" error:nil];
```

Then you can pass the transaction to receiver, who can send transaction to
on-chain later:

```objective-c
NSString *nanoTxnHash = [wallet sendRawTransaction:txn error:nil];
```

Register name for this wallet

```objective-c
NSLog(@"txn hash: %@", [wallet registerName:@"somename" config:transferConf error:nil]);
```

Delete name for this wallet

```objective-c
NSLog(@"txn hash: %@", [wallet deleteName:@"comename" config:transferConf error:nil]);
```

Subscribe to specified topic for this wallet for next 100 blocks

```objective-c
NSLog(@"txn hash: %@", [wallet subscribe:@"identifier" topic:@"topic" duration:100 meta:@"meta" config:transferConf error:nil]);
```

Unsubscribe from specified topic

```objective-c
NSLog(@"txn hash: %@", [wallet unsubscribe:@"identifier" topic:@"topic" config:transferConf error:nil]);
```

## Community

- [Forum](https://forum.nkn.org/)
- [Discord](https://discord.gg/c7mTynX)
- [Telegram](https://t.me/nknorg)
- [Reddit](https://www.reddit.com/r/nknblockchain/)
- [Twitter](https://twitter.com/NKN_ORG)
