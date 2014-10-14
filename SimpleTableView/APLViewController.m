//
//  APLViewController.m
//  SimpleTableView
//
//  Created by Ratheesh Reddy on 10/8/14.
//  Copyright (c) 2014 Ventois. All rights reserved.
//

#import "APLViewController.h"
#import <sqlite3.h>

// Private methods.
@interface APLViewController ()

@property (nonatomic) sqlite3 *barcodesDB;

@property (strong, nonatomic) NSString *databasePath;

@property (strong, nonatomic) NSMutableArray* scannedBarCodes;

@property (strong, nonatomic) NSString *barcode;

@property (nonatomic) int value;

-(void) showReaderView;

- (BOOL) saveBarcode:(NSString *)itemBarcode numberOfTimes: (int)scanned;

@end

@implementation APLViewController

- (void)viewDidLoad
{
    self.scannedBarCodes = [[NSMutableArray alloc] init];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                           target:self
                                                                                           action:@selector(showReaderView)];
    [super viewDidLoad];
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    // Build the path to the database file and create a table within the database in which to store the barcode and the value scanned by the user
    _databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent: @"barcodescanner.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: _databasePath ] == NO)
    {
        const char *dbpath = [_databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &_barcodesDB) == SQLITE_OK)
        {
            char *errMsg;
            
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS ScannedItems (Barcode PRIMARY KEY TEXT, Value INTEGER)";
            
            if (sqlite3_exec(_barcodesDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table");
            }
            
            sqlite3_close(_barcodesDB);
            
        }
        
       else
        {
            NSLog(@"Failed to open/create database");
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    
    [super viewWillAppear:animated];
}
/*
 There's no need to implement numberOfSectionsInTableView: because there's only one section and the method defaults to returning 1.
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of scanned barcodes.
	return [self.scannedBarCodes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

	static NSString *MyIdentifier = @"MyIdentifier";

	/*
     Retrieve a cell with the given identifier from the table view.
     The cell is defined in the main storyboard: its identifier is MyIdentifier, and  its selection style is set to None.
     */
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];

	// Set up the cell.
    
	NSString *timeZoneName = [self.scannedBarCodes objectAtIndex:indexPath.row];
    
	cell.textLabel.text = timeZoneName;

	return cell;
}

-(void) showReaderView
{
    CameraViewController* cameraView = [[CameraViewController alloc] initWithDelegate:self];
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:cameraView];
    
    [self presentViewController:navController animated:YES completion:nil];

}

-(void)scanCompletedWithString:(NSArray*)barCodes
{
    
    for (NSString* barCode in barCodes)
    {
        [self saveBarcode:barCode numberOfTimes:1];
    }
    
    [self.scannedBarCodes addObjectsFromArray:barCodes];
    
    NSLog(@"The Barcode vlaue is:%@", [barCodes description]);
    
}

// Save our scanned barcode data
- (BOOL) saveBarcode:(NSString *)itemBarcode numberOfTimes:(int)scanned
{
    BOOL success = false;
    
    sqlite3_stmt *statement = NULL;
    
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_barcodesDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"Select Barcode, Value from ScannedItems where Barcode=\"%@\" ",itemBarcode];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_barcodesDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
                
            {
            //Update Existing data
            NSLog(@"Existing data, Update please ");
            
            NSString *updateSQL = [NSString stringWithFormat:@"UPDATE ScannedItems set Value = '%d' WHERE Barcode = ?", ++scanned];
            
            const char *update_stmt = [updateSQL UTF8String];
            
            sqlite3_prepare_v2(_barcodesDB, update_stmt, -1, &statement, NULL );
            
            sqlite3_bind_int(statement, 1, itemBarcode);
            
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                success = true;
            }
            
        }
        
        else
        {
            // Insert values into the ScannedItem Table
            NSLog(@"New data, Insert Please");
            
            NSString *insertSQL = [NSString stringWithFormat:
                                   @"INSERT INTO ScannedItems (barcode, value) VALUES (\"%@\", \"%d\")", itemBarcode, scanned];
            
            const char *insert_stmt = [insertSQL UTF8String];
            
            sqlite3_prepare_v2(_barcodesDB, insert_stmt, -1, &statement, NULL);
            
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                success = true;
            }
        }
        
        sqlite3_finalize(statement);
            
        }
        
        sqlite3_close(_barcodesDB);
        
}
    return success;
}

@end
    

