//
//  ViewController.m
//  iphone
//
//  Created by Geaving Team on 2022/2/14.
//

#import "ViewController.h"
#import "Nkn.framework/Headers/Nkn.objc.h"
#import <NetworkExtension/NetworkExtension.h>

@interface ViewController ()<NknOnMessageFunc, NknOnConnectFunc>
{
    NknClient *clientA;
    NknClient *clientB;
    
    NknMultiClient *multiClientA;
    NknMultiClient *multiClientB;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //By default the client will use bootstrap RPC server (for getting node address) provided by NKN.
    NknClientConfig *conf = [NknClientConfig new];
    //Any NKN full node can serve as a bootstrap RPC server. To create a client using customized bootstrap RPC server:
    //[conf setSeedRPCServerAddr:[[NkngomobileStringArray alloc] initFromString:@"https://ip:port"]];
    
    //Create a account using an existing secret seed:
    NknAccount *accountA = [[NknAccount alloc] init:[@"70016750081905799396851717434796" dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"account seed: %@", [[NSString alloc] initWithData:accountA.seed encoding:NSUTF8StringEncoding]);
    //NSLog(@"account public key: %@", [[NSString alloc] initWithData:accountA.pubKey encoding:NSUTF8StringEncoding]);
    
    //Create a client by account using id(any string or nil) and config
    clientA = [[NknClient alloc] init:accountA identifier:@"clientA" config:conf];
    NSLog(@"clientA address: %@", clientA.address);
    //Listen for connection
    [clientA.onConnect setCallback:self];
    
    //Create clientB to receive message
    NknAccount *accountB = [[NknAccount alloc] init:[@"98779800404564869404649303020039" dataUsingEncoding:NSUTF8StringEncoding]];
    clientB = [[NknClient alloc] init:accountB identifier:@"clientB" config:conf];
    [clientB.onConnect setCallback:self];
    //Receive data from other clients
    [clientB.onMessage setCallback:self];
    
    //clientA send a text message to clientB
    [clientA sendText:[[NkngomobileStringArray alloc] initFromString:clientB.address] data:@"Hello clientB, I am clientA..." config:nil error:nil];
    
    //Create a multiclient by account with 3 sub client
    multiClientA = [[NknMultiClient alloc] init:accountA baseIdentifier:nil numSubClients:3 originalClient:true config:conf];
    //Same as client
    [multiClientA.onConnect setCallback:self];
    
    //Create multiClientB to receive message
    multiClientB = [[NknMultiClient alloc] init:accountB baseIdentifier:nil numSubClients:3 originalClient:true config:conf];
    [multiClientB.onConnect setCallback:self];
    [multiClientB.onMessage setCallback:self];
    
    //multiClientA send a text message to multiClientB
    [multiClientA sendText:[[NkngomobileStringArray alloc] initFromString:multiClientB.address] data:@"Hello multiClientB, I am multiClientA..." config:nil error:nil];
    
    //By default the wallet will use RPC server provided by nkn.org.
    NknWalletConfig *walletConf = [NknWalletConfig new];
    walletConf.password = @"abc123";
    //Any NKN full node can serve as a RPC server. To create a wallet using customized RPC server:
    //walletConf.seedRPCServerAddr = [[NkngomobileStringArray alloc] initFromString:@"https://ip:port"];
    
    //Create a wallet
    NknWallet *wallet = [[NknWallet alloc] init:accountA config:walletConf];
    
    //Export wallet to JSON string, where sensitive contents are encrypted by password provided in config:
    NSLog(@"wallet to JSON string: %@", [wallet toJSON:nil]);
    
    //Verify password of the wallet:
    if ([wallet verifyPassword:@"abc123" error:nil]) {
        NSLog(@"provided password is the correct password of this wallet");
    }
    
    //Query asset balance with background context:
    NSLog(@"balance: %@", [wallet balance:nil].string);
    
    //Query asset balance for address:
    //NSLog(@"balance: %@", [wallet balanceByAddress:@"NKNxxxxx" error:nil].string);
    
    //Create a transaction config, you can set fee or nonce or other attributes
    NknTransactionConfig *transferConf = [NknTransactionConfig new];
    transferConf.fee = @"0.01";
    //Transfer asset to some address:
    NSString *txnHash = [wallet transfer:accountA.walletAddress amount:@"100" config:transferConf error:nil];
    NSLog(@"txn hash: %@", txnHash);
    
    //Open nano pay channel to specified address:
    NknNanoPay *nanoPay = [wallet newNanoPay:@"NKNxxxxx" fee:@"0.01" duration:4320 error:nil];
    //Increment channel balance by 100 NKN:
    TransactionTransaction *txn = [nanoPay incrementAmount:@"100" error:nil];
    //Then you can pass the transaction to receiver, who can send transaction to on-chain later:
//    NSString *nanoTxnHash = [wallet sendRawTransaction:txn error:nil];
//    NSLog(@"txn hash: %@", nanoTxnHash);
    
    //Register name for this wallet:
    NSLog(@"txn hash: %@", [wallet registerName:@"somename" config:transferConf error:nil]);
    //Delete name for this wallet:
    NSLog(@"txn hash: %@", [wallet deleteName:@"comename" config:transferConf error:nil]);
    
    //Subscribe to specified topic for this wallet for next 100 blocks:
    NSLog(@"txn hash: %@", [wallet subscribe:@"identifier" topic:@"topic" duration:100 meta:@"meta" config:transferConf error:nil]);
    //Unsubscribe from specified topic:
    NSLog(@"txn hash: %@", [wallet unsubscribe:@"identifier" topic:@"topic" config:transferConf error:nil]);
    
}

- (void)onConnect:(NknNode *)p0 {
    //do something
    //NSLog(@"onConnect: opened");
}

- (void)onMessage:(NknMessage *)p0 {
    NSLog(@"message received from %@, data: %@", p0.src, [[NSString alloc] initWithData:p0.data encoding:NSUTF8StringEncoding]);
}

@end
