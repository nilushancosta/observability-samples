// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 Inc. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import ballerina/http;
import ballerina/lang.runtime;
import ballerina/log;

service / on new http:Listener(8090) {
    resource function get [string employeeId](http:Caller caller) returns error? {
        runtime:sleep(1);
        if (employeeId.equalsIgnoreCaseAscii("2")) {
            runtime:sleep(3);
        } else if (employeeId.equalsIgnoreCaseAscii("500")) {
            http:Response errorResponse = new;
            errorResponse.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
            errorResponse.setPayload("backend-service failure");
            error? ret = caller->respond(errorResponse);
            if (ret is error) {
                log:printError("responding to client failed", 'error = ret);
            }
            return;
        }
        map<json> employees = {
            "1": {
                id: "1",
                firstName: "Andy",
                lastName: "Cook",
                departmentId: "1",
                title: "Manager"
            },
            "2": {
                id: "2",
                firstName: "Jim",
                lastName: "Smith",
                departmentId: "2",
                title: "Software Engineer"
            },
            "3": {
                id: "3",
                firstName: "Sara",
                lastName: "Jackson",
                departmentId: "4",
                title: "Accountant"
            }
        };

        json employee = employees[employeeId];
        if employee is () {
            http:Response errorResponse = new;
            errorResponse.statusCode = http:STATUS_NOT_FOUND;
            errorResponse.setPayload("requested data not found in hr-service");
            error? ret = caller->respond(errorResponse);
            if (ret is error) {
                log:printError("responding to client failed", 'error = ret);
            }
        } else {
            error? ret = caller->respond(employee);
            if (ret is error) {
                log:printError("responding to client failed", 'error = ret);
            }
        }
    }
}
