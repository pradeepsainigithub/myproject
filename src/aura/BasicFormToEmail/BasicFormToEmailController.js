({  
    handleClick : function(component,event,helper)
    {
        var valid = component.find('formValid').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        if(valid){
            var emailDetails = new Object();
            emailDetails['fullName'] = component.get("v.fullName");
            emailDetails['emailAddress'] = component.get("v.emailAddress");
            emailDetails['summaryIssue'] = component.get("v.summaryIssue");
            var action = component.get("c.sendEmail");
            action.setParams({
                "emailDetails" : JSON.stringify(emailDetails)
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                var result = response.getReturnValue();
                if (state === "SUCCESS") {                     
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "EMail Send"
                    });
                    toastEvent.fire();
                    var toggleText = component.find("hideId");
                    $A.util.toggleClass(toggleText,	'slds-hide');
                     var alert = component.find("showId");
                    $A.util.removeClass(alert,'slds-hide');
                }
                else if (state === "ERROR") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Something has gone wrong!!!"
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
        }
    }
})