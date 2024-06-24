// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 Inc. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import ballerina/http;
import ballerina/log;
import ballerina/lang.runtime;

service / on new http:Listener(8090) {
    resource function get [string departmentId](http:Caller caller) returns error? {
        log:printInfo("Received a request to fetch department details of department " + departmentId);
        map<json> departments = {
            "1": {id: "1", name: "Finance"},
            "2": {id: "2", name: "Marketing"},
            "3": {id: "3", name: "Sales"},
            "4": {id: "4", name: "Engineering"}
        };

        json department = departments[departmentId];
        if department is () {
            http:Response response = new;
            response.statusCode = http:STATUS_NOT_FOUND;
            error? ret = caller->respond(response);
            if (ret is error) {
                log:printError("responding to client failed", 'error = ret);
            }
        } else {
            // Sleep for 1 second
            runtime:sleep(10);
            error? ret = caller->respond(department);
            if (ret is error) {
                log:printError("responding to client failed", 'error = ret);
            }
        }
    }
}
