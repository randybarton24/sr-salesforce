declare module "@salesforce/apex/PlaybookControllerApxc.getPlaybookCaseApx" {
  export default function getPlaybookCaseApx(param: {acctId: any}): Promise<any>;
}
declare module "@salesforce/apex/PlaybookControllerApxc.getPlaybookAsList" {
  export default function getPlaybookAsList(): Promise<any>;
}
declare module "@salesforce/apex/PlaybookControllerApxc.addPlaybookCaseApx" {
  export default function addPlaybookCaseApx(param: {acctId: any, playbookId: any}): Promise<any>;
}
declare module "@salesforce/apex/PlaybookControllerApxc.AddActivityApx" {
  export default function AddActivityApx(param: {TaskId: any, isTask: any, newTask: any, newEvent: any, CaseId: any}): Promise<any>;
}
declare module "@salesforce/apex/PlaybookControllerApxc.getAllTasksApx" {
  export default function getAllTasksApx(param: {caseId: any, relatedPlay: any}): Promise<any>;
}
declare module "@salesforce/apex/PlaybookControllerApxc.getAllEventsApx" {
  export default function getAllEventsApx(param: {caseId: any, relatedPlay: any}): Promise<any>;
}
declare module "@salesforce/apex/PlaybookControllerApxc.updateTasksApx" {
  export default function updateTasksApx(param: {taskId: any, completedStatus: any}): Promise<any>;
}
declare module "@salesforce/apex/PlaybookControllerApxc.updateEventApx" {
  export default function updateEventApx(param: {eventId: any, completedStatus: any}): Promise<any>;
}
declare module "@salesforce/apex/PlaybookControllerApxc.closePlaybookCaseApx" {
  export default function closePlaybookCaseApx(param: {CaseID: any, resolution: any, resDescription: any}): Promise<any>;
}
