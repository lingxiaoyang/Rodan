@import "../Controllers/WorkflowController.j"

@implementation WorkflowDesignerJobSettingsDelegate : CPObject
{
}

////////////////////////////////////////////////////////////////////////////////////////////
// Public Methods
////////////////////////////////////////////////////////////////////////////////////////////
- (id)init
{
    return self;
}

/**
 * Saves currently selected workflow job settings.
 */
- (@action)saveCurrentlySelectedWorkflowJobSettings:(id)aSender
{
    var workflow = [WorkflowController activeWorkflow];
    if (workflow != nil)
    {
        [workflow touchWorkflowJobs];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////
// Handler Methods
////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(CPTableView)aTableView willDisplayView:(id)aView forTableColumn:(CPTableColumn)aTableColumn row:(int)rowIndex;
{
    if ([aTableColumn identifier] !== 'valueColumn')
    {
        return;
    }

    // Remove current subviews.
    [aView setSubviews:[[CPArray alloc] init]];

    // Get job settings.
    var workflowJobSetting = [aView objectValue];
    if (workflowJobSetting === nil)
    {
        return;
    }

    // Create view based on type and format.
    var dataView = [WorkflowDesignerJobSettingsDelegate _createDataViewForWorkflowJobSetting:workflowJobSetting];
    [dataView sizeToFit];
    [dataView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [aView addSubview:dataView];
    [dataView setFrame:[[dataView superview] bounds]];
}

////////////////////////////////////////////////////////////////////////////////////////////
// Private Static Methods
////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Given a workflow job setting model, returns appropriate data view.
 * The resulting control will be created, bound, and value initialized, but not formatted.
 */
+ (CPControl)_createDataViewForWorkflowJobSetting:(WorkflowJobSetting)aSetting
{
    if (aSetting === nil)
    {
        return;
    }

    var dataView = nil;
    switch ([aSetting settingType])
    {
        case 'int':
        {
            dataView = [WorkflowDesignerJobSettingsDelegate _createTextField:aSetting];
            break;
        }

        case 'uuid_workflowjob':
        {
            dataView = [WorkflowDesignerJobSettingsDelegate _createWorkflowJobPopUpButton:aSetting];
            break;
        }

        case 'choice':
        {
            dataView = [CPTextField labelWithTitle:""];
            break;
        }

        default:
        {
            dataView = [CPTextField labelWithTitle:""];
            break;
        }
    }

    // Initialize, bind, return.
    return dataView;
}

/**
 * Given a workflow job setting, creates a text-field and binds to the setting.
 */
+ (CPTextField)_createTextField:(WorkflowJobSetting)aSetting
{
    var textField = [CPTextField labelWithTitle:""];
    if (aSetting === nil)
    {
        return button;
    }
    [textField setEditable:YES];
    [textField setBezeled:YES];
    [textField setObjectValue:[aSetting settingDefault]];
    [textField setStringValue:[aSetting settingDefault]];
    [aSetting bind:"settingDefault" toObject:textField withKeyPath:"objectValue" options:null];
    return textField;
}

/**
 * Given a workflow job setting, create a pop-up button that allows selection of workflow jobs
 * for the currently selected workflow.  The value is bound to the pk/uuid of the job.
 *
 * NOTE: It does NOT check the sequence or job name, so the user should know what they're doing.
 */
+ (CPPopUpButton)_createWorkflowJobPopUpButton:(WorkflowJobSetting)aSetting
{
    // Nil check.
    var button = [[CPPopUpButton alloc] init];
    if (aSetting === nil)
    {
        return button;
    }

    // Nil check.
    var workflow = [WorkflowController activeWorkflow];
    if (workflow === nil)
    {
        return button;
    }

    // Nil check.
    var workflowJobs = [workflow workflowJobs];
    if (workflowJobs === nil || [workflowJobs count] === 0)
    {
        return button;
    }

    // Enumerate through jobs and add menu items to the button.
    // Also, look for the current setting (if there).
    var jobEnumerator = [workflowJobs objectEnumerator],
        job = null,
        defaultSelection = nil;
    while (job = [jobEnumerator nextObject])
    {
        // Create and add item.
        var menuItem = [[CPMenuItem alloc] initWithTitle:[job jobName] action:null keyEquivalent:null];
        [menuItem setRepresentedObject:[job pk]];
        [button addItem:menuItem];

        // Check if the pk matches the current setting.  If it does, THIS one should be our default item.
        if ([aSetting settingDefault] === [job pk])
        {
            defaultSelection = menuItem;
        }
    }

    // Initialize, bind, return.
    if (defaultSelection === nil)
    {
        [button selectItemAtIndex:0];
    }
    else
    {
        [button selectItem:defaultSelection];
    }
    [aSetting bind:"settingDefault" toObject:button withKeyPath:"selectedItem.representedObject" options:null];
    return button;
}
@end
