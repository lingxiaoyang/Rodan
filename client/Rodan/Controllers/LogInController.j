@import <AppKit/AppKit.j>
@import "../Models/User.j"

@global RodanMustLogInNotification
@global RodanCannotLogInNotification
@global RodanDidLogInNotification
@global RodanDidLogOutNotification

@implementation LogInController : CPObject
{
    @outlet     CPTextField       usernameField;
    @outlet     CPSecureTextField passwordField;
    @outlet     CPButton          submitButton;
    @outlet     CPWindow          logInWindow;
                CPCookie          CSRFToken;
}

- (void)runLogInSheet
{
    [logInWindow setDefaultButton:submitButton];

    [CPApp beginSheet:logInWindow modalForWindow:[CPApp mainWindow] modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)closeSheet:(id)aSender
{
    [CPApp endSheet:logInWindow returnCode:[aSender tag]];
}

- (void)didEndSheet:(CPWindow)aSheet returnCode:(int)returnCode contextInfo:(id)contextInfo
{
    [logInWindow orderOut:self];
    [self logIn];
}

- (void)logIn
{
    var username = [usernameField objectValue],
        password = [passwordField objectValue];
    CSRFToken = [[CPCookie alloc] initWithName:@"csrftoken"];

    var request = [CPURLRequest requestWithURL:@"/auth/session/"];
    [request setValue:[CSRFToken value] forHTTPHeaderField:@"X-CSRFToken"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]
    [request setHTTPBody:@"username=" + username + "&password=" + password];
    [request setHTTPMethod:@"POST"];

    var conn = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(CPURLConnection)connection didFailWithError:(id)error
{
    CPLog("Failed with Error");
}

- (void)connection:(CPURLConnection)connection didReceiveResponse:(CPURLResponse)response
{
    switch ([response statusCode])
    {
        case 400:
            CPLog("Received 400 Bad Request");
            alert = [[CPAlert alloc] init];
            [alert setMessageText:@"Error."];
            [alert setAlertStyle:CPWarningAlertStyle];
            [alert addButtonWithTitle:@"Try Again"];
            [alert runModal];

            [connection cancel];
        case 401:
            // UNAUTHORIZED
            [[CPNotificationCenter defaultCenter] postNotificationName:RodanMustLogInNotification
                                                  object:nil];

            [connection cancel];
            break;
        case 403:
            // FORBIDDEN
            [[CPNotificationCenter defaultCenter] postNotificationName:RodanCannotLogInNotification
                                                  object:nil];

            [connection cancel]
            break;
        case 404:
            // NOT FOUND
            break;
        default:
            console.log("I received a status code of " + [response statusCode]);
    }
}

- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
    if (data)
    {
        var data = JSON.parse(data),
            resp = [CPDictionary dictionaryWithJSObject:data];
        [[CPNotificationCenter defaultCenter] postNotificationName:RodanDidLogInNotification
                                              object:resp];
    }
}

@end


@implementation LogInCheckController : CPObject
{
}

- (LogInCheckController)initCheckingStatus
{
    if (self = [super init])
    {
        var request = [CPURLRequest requestWithURL:@"/auth/status/"];
        [request setHTTPMethod:@"GET"];
        var conn = [CPURLConnection connectionWithRequest:request delegate:self];
    }
    return self;
}

- (void)connection:(CPURLConnection)connection didFailWithError:(id)error
{
    CPLog("Failed with Error");
}

- (void)connection:(CPURLConnection)connection didReceiveResponse:(CPURLResponse)response
{
    switch ([response statusCode])
    {
        case 200:
            // Success
            break;
        case 400:
            // BAD REQUEST
            [connection cancel];
        case 401:
            // UNAUTHORIZED
            [[CPNotificationCenter defaultCenter] postNotificationName:RodanMustLogInNotification
                                                  object:nil];
            [connection cancel];
            break;
        case 403:
            // FORBIDDEN
            [[CPNotificationCenter defaultCenter] postNotificationName:RodanCannotLogInNotification
                                                  object:nil];
            [connection cancel];
            break;
        case 404:
            // NOT FOUND
            [connection cancel];
            break;
        default:
            console.log("I received a status code of " + [response statusCode]);
    }
}

- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
    if (data)
    {
        var data = JSON.parse(data),
            user = [[User alloc] initWithJson:data];
        [[CPNotificationCenter defaultCenter] postNotificationName:RodanDidLogInNotification
                                              object:user];
    }
}

@end


@implementation LogOutController : CPObject
{
}

+ (void)logOut
{
    var obj = [[LogOutController alloc] init];

    var CSRFToken = [[CPCookie alloc] initWithName:@"csrftoken"],
        request = [CPURLRequest requestWithURL:@"/auth/logout/"];
    [request setValue:[CSRFToken value] forHTTPHeaderField:@"X-CSRFToken"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    var conn = [CPURLConnection connectionWithRequest:request delegate:obj];
}

- (void)connection:(CPURLConnection)connection didFailWithError:(id)error
{
    CPLog("Failed with Error");
}

- (void)connection:(CPURLConnection)connection didReceiveResponse:(CPURLResponse)response
{
    switch ([response statusCode])
    {
        case 200:
            // Success
            [[CPNotificationCenter defaultCenter] postNotificationName:RodanDidLogOutNotification
                                                  object:nil];
            break;
        case 400:
            // BAD REQUEST
            [connection cancel];
        case 401:
            // UNAUTHORIZED
            [connection cancel];
            break;
        case 403:
            // FORBIDDEN
            [connection cancel];
            break;
        case 404:
            // NOT FOUND
            [connection cancel];
            break;
        default:
            console.log("I received a status code of " + [response statusCode]);
    }
}

- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
}

@end
