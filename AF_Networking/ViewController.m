//
//  ViewController.m
//  AF_Networking
//
//  Created by L on 2018/5/18.
//  Copyright © 2018年 L. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking/AFNetworking.h>

static NSString * const tokenID = @"eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL2Rldi5pemhpanUuY24vYXBpIiwiaWF0IjoxNTI2NjM0ODY3LCJleHAiOjE1MjY2MzY2NjcsInN1YiI6IlJZLWtYbTQzei1ZIiwic0lkIjoiUUphV2ZXSTlmeUkifQ.r8ZmOTy4fvPhkzJ0CoHyIUiRQ2dqNQLOiCKlSaaU6tPSAqZNgwolmDN2pYSXuatKEOBADHEAVt_YRErX9AHVcjUPGm7QRSowQLu5ZC8un3269sBERpO9DpQ2hRagwtGpm5ChsrsB-GWnf8kgT4Rl5Ag4aYO3jAVnndIX28O8moPRZunumiFaNVdtLdKMHgFc9Td96iEBJ1VfHG312TQ-txnstAFlTI3QNvFgTbMhi8FDPgVD1T1W-YJHB1OmhQj5bo72U3wUrPtApWAbVBaY9DawUqkfE_0y-66ag90HEzWo94BR9O9TJbA8gPlNjiyZ-r04JnhmxE1hnupfAKDZ-BWR5cmfgBCZ_CzQQm9LcE5fI9HCQz7W1BkaZ3SUWq2BwG6us_wUPgAh3qd80qgEh3RcpCLo6rDjYfqBHZp9msI0QYi8UT-kHYvs91KYGz4Sma8msfD-K01P15F9UFXWMsoCbNirllrx0Vb8EYu7MyTZh6tEKX48ZRNfXS-gN5T50gavwa2aS52_O4FMvyoNIMH1EDHt2XgZ98sD1C5k1X8L_IFGkGLIt9g5K7bnGOayo13UAnwd0nHpCdnbFaVKrWCCS8VJUFeqkmbzWNbD0Vdqxlq1dqLQa85gOF3XwTxcUcDRHbPd-ERBVfMmkYNk8NTB93R2SgPrc5lhfjtpBps";

@interface ViewController () {
    NSData *uploadData;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    uploadData = UIImagePNGRepresentation([UIImage imageNamed:@"apropos.png"]);
    
    [self uploadFileUseOriginMethod];
//    [self uploadFileUseAFNetworking];
}

- (void)uploadFileUseOriginMethod {
    
    NSMutableURLRequest *mutalbeURLRequest = [[NSMutableURLRequest alloc]init];
    
    mutalbeURLRequest.HTTPMethod = @"POST";
    mutalbeURLRequest.URL = [NSURL URLWithString:@""];
    
    NSString *boundary = [NSString stringWithFormat:@"Boundary+%08X%08X", arc4random(), arc4random()];
    
    mutalbeURLRequest.allHTTPHeaderFields = @{
                                              @"Content-Type": [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary],
                                              @"Authorization": [NSString stringWithFormat:@"Bearer %@", tokenID]
                                              };
    
#pragma mark - multipart/form-data格式按照构建上传数据
  
    NSMutableData *postData = [[NSMutableData alloc]init];
    
    /* body部分
    NSDictionary *bodyDict = @{};
     
    for (NSString *key in bodyDict) {
        NSString *pair = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n",boundary,key];
        [postData appendData:[pair dataUsingEncoding:NSUTF8StringEncoding]];
        
        id value = [bodyDict objectForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            [postData appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
        }else if ([value isKindOfClass:[NSData class]]){
            [postData appendData:value];
        }
        [postData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    */
    
    //文件部分
   
    NSString *filePair = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name = \"%@\"; filename = \"%@\"; Content-Type = %@\r\n\r\n", boundary, @"name", @"jjj.png", @"image/png"];

    [postData appendData:[filePair dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:self->uploadData]; //加入文件的数据
    
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    [mutalbeURLRequest setValue:[NSString stringWithFormat:@"%lu",(unsigned long)postData.length] forHTTPHeaderField:@"Content-Length"];
    
    [[[NSURLSession sharedSession] uploadTaskWithRequest:mutalbeURLRequest fromData:postData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
          NSLog(@"--- %@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
          NSLog(@"%@", response);
          NSLog(@"==== %@", error);
    }]resume];
    
}

- (void)uploadFileUseAFNetworking {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer= [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", tokenID] forHTTPHeaderField:@"Authorization"];
    [manager POST:@"" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        [formData appendPartWithFileData:self->uploadData name:@"file" fileName:@"jjjj.png" mimeType:@"image/png"];
        NSLog(@"%@", formData);
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSString *str = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"%@", str);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"上传失败%@",error);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
